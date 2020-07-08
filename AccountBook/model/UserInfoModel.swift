//
//  UserInfoModel.swift
//  AnyReview
//
//  Created by Changyul Seo on 2020/06/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseFirestore

var FS:Firestore {
    Firestore.firestore()
}

var loginedEmail:String = ""

fileprivate var db:CollectionReference {
    FS.collection(.FSCollectionName_user)
}

class UserInfoModel: Object {
    @objc dynamic var name:String = ""
    @objc dynamic var email:String = ""
    @objc dynamic var profileImageURLgoogle:String = ""
    @objc dynamic var profileImageURLfirebase:String = ""
    @objc dynamic var isDeleteProfileImage:Bool = true
    @objc dynamic var updateTimeIntervalSince1970:Double = 0
    @objc dynamic var point:Int = 0
    @objc dynamic var exp:Int = 0
    @objc dynamic var token:String = ""
    override static func primaryKey() -> String? {
        return "email"
    }
    
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
}

extension UserInfoModel {
    static var myInfo:UserInfoModel? {        
        try! Realm().object(ofType: UserInfoModel.self, forPrimaryKey: loginedEmail)
    }
    
    var profileImageURL:URL? {
        if isDeleteProfileImage {
            return nil
        }
        if profileImageURLfirebase.isEmpty == false {
            return URL(string: profileImageURLfirebase)
        }
        if profileImageURLgoogle.isEmpty == false {
            return URL(string: profileImageURLgoogle)
        }
        return nil
    }
}


extension UserInfoModel {
    /** 사용자 정보 가져오기 */
    static func getUserInfo(email:String, complete:@escaping(_ isSucess:Bool)->Void) {
        db.document(email).getDocument { (snapshot, error) in
            if error == nil {
                if let doc = snapshot {
                    if doc.data()?.count == 0 || doc.data() == nil {
                        complete(false)
                        return
                    }
                    doc.data().map { info in
                        let realm = try! Realm()
                        realm.beginWrite()
                        realm.create(UserInfoModel.self, value: info, update: .modified)
                        try! realm.commitWrite()
                        complete(true)
                    }
                }
            } else {
                complete(false)
            }
        }
    }
    /** 사용자 정보 생성하기 (회원가입)*/
    static func createUserInfo(email:String, name:String, uploadProfileImageURL:URL?, complete:@escaping(_ isSucess:Bool)->Void) {
        var data:[String:Any] = [
            "email":email,
            "name":name
        ]
        if let url = uploadProfileImageURL {
            data["profileImageURLfirebase"] = url.absoluteString
        }
        db.document(email).setData(data) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(UserInfoModel.self, value: data, update: .all)
                try! realm.commitWrite()
            }
            complete(error == nil)
        }
    }
    
    func updateUserInfo(name:String, uploadProfileImageURL:String?, isDeleteProfile:Bool ,complete:@escaping(_ isSucess:Bool)->Void) {
        var data:[String:Any] = [
            "email" : email,
            "name" : name,
            "isDeleteProfileImage" : isDeleteProfile
        ]
        if let url = uploadProfileImageURL {
            data["profileImageURLfirebase"] = url
        }
        db.document(email).updateData(data) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(UserInfoModel.self, value: data, update: .all)
                try! realm.commitWrite()
            }
            complete(error == nil)
        }
    }
}
