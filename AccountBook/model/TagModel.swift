//
//  TagModel.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/07.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseFirestore

fileprivate var db:CollectionReference {
    FS.collection(.FSCollectionName_accountData).document(loginedEmail).collection(.FSCollectionName_accounts_tag)
}

fileprivate var publidDB:CollectionReference {
    FS.collection(.FSCollectionName_public_accountData).document(.FSCollectionName_public_accountData).collection(.FSCollectionName_accounts_tag)
}

class TagModel: Object {
    @objc dynamic var creatorEmail:String = ""
    @objc dynamic var title:String = ""
    @objc dynamic var regTimeIntervalSince1970:Double = Date().timeIntervalSince1970
    override static func primaryKey() -> String? {
        return "title"
    }
    
    override static func indexedProperties() -> [String] {
        return ["creatorEmail","title"]
    }
}

extension TagModel {
    var regDt:Date {
        return Date(timeIntervalSince1970: regTimeIntervalSince1970)
    }
    
    var creator:UserInfoModel? {
        return try! Realm().object(ofType: UserInfoModel.self, forPrimaryKey: creatorEmail)
    }
}

extension TagModel {
    static func sync(isPublic:Bool = false, complete:@escaping(_ isSucess:Bool)->Void) {
        let realm = try! Realm()
        let collection = isPublic ? publidDB : db
        var query = collection.whereField("regTimeIntervalSince1970", isGreaterThan: 0)
        if isPublic {
            if let time = realm.objects(TagModel.self).sorted(byKeyPath: "regTimeIntervalSince1970").last?.regTimeIntervalSince1970 {
                query = collection.whereField("regTimeIntervalSince1970", isGreaterThan: time)
            }
        } else {
            if let time = realm.objects(TagModel.self).filter("creatorEmail = %@",loginedEmail).sorted(byKeyPath: "regTimeIntervalSince1970").last?.regTimeIntervalSince1970 {
                query = collection.whereField("regTimeIntervalSince1970", isGreaterThan: time)
            }
        }
        
        query.getDocuments { (snapShot, error) in
            if let err = error {
                debugPrint(err.localizedDescription)
                complete(false)
                return
            }
            guard let data = snapShot?.documents else {
                complete(false)
                return
            }
            if data.count > 0 {
                let realm = try! Realm()
                realm.beginWrite()
                for shot in data {
                    realm.create(TagModel.self, value: shot.data(), update: .all)
                }
                try! realm.commitWrite()
            }
            complete(true)
        }
    }
    
    static func getInfo(title:String, isFromPublic:Bool = false ,complete:@escaping(_ isSucess:Bool)->Void) {
        (isFromPublic ? publidDB : db).document(title).getDocument { (snapShot, error) in
            if let data = snapShot?.data() {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(TagModel.self, value: data, update: .all)
                try! realm.commitWrite()
            }
            complete(error == nil && snapShot?.data() != nil)
        }
    }
    
    static func createTag(title:String, isCreatePublic:Bool = false, complete:@escaping(_ isSucess:Bool)->Void) {
        func make(isPublic:Bool,complete:@escaping(_ isSucess:Bool)->Void) {
            getInfo(title: title, isFromPublic: isPublic) { (isSucess) in
                if isSucess {
                    complete(true)
                } else {
                    let data:[String:Any] = [
                        "creatorEmail":loginedEmail,
                        "title":title,
                        "regTimeIntervalSince1970":Date().timeIntervalSince1970
                    ]
                    (isPublic ? publidDB : db).document(title).setData(data) { (error) in
                        if error == nil {
                            let realm = try! Realm()
                            realm.beginWrite()
                            realm.create(TagModel.self, value: data, update: .all)
                            try! realm.commitWrite()
                        }
                        complete(error == nil)
                    }
                }
            }
        }
        if isCreatePublic {
            make(isPublic: true) { (a) in
                make(isPublic: false) { (b) in
                    complete(a && b)
                }
            }
        } 
        else {
            make(isPublic: false) { (isSucess) in
                complete(isSucess)
            }
        }
    }
}
 
