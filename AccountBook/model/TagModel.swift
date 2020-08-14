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
    FS.collection(.FSCollectionName_tags)
}

class TagModel: Object {
    @objc dynamic var creatorEmail:String = ""
    @objc dynamic var title:String = ""
    @objc dynamic var regTimeIntervalSince1970:Double = Date().timeIntervalSince1970
    @objc dynamic var latitude:Double = 0
    @objc dynamic var longitude:Double = 0
    
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
    static func sync(complete:@escaping(_ isSucess:Bool)->Void) {
        let realm = try! Realm()
        let collection =  db
        var query = collection.whereField("regTimeIntervalSince1970", isGreaterThan: 0)
        if let time = realm.objects(TagModel.self).sorted(byKeyPath: "regTimeIntervalSince1970").last?.regTimeIntervalSince1970 {
            query = collection.whereField("regTimeIntervalSince1970", isGreaterThan: time)
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
    
    static func getInfo(title:String,complete:@escaping(_ isSucess:Bool)->Void) {
        db.document(title).getDocument { (snapShot, error) in
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
        func make(complete:@escaping(_ isSucess:Bool)->Void) {
            getInfo(title: title) { (isSucess) in
                if isSucess {
                    complete(true)
                } else {
                    let data:[String:Any] = [
                        "creatorEmail":loginedEmail,
                        "title":title.trimmingValue,
                        "regTimeIntervalSince1970":Date().timeIntervalSince1970
                    ]
                    db.document(title).setData(data) { (error) in
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
        make { (isSucess) in
            complete(isSucess)
        }
    }
}
 
