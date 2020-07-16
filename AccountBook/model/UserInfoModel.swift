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

extension Notification.Name {
    static let profileUpdatedNotification = Notification.Name("profileUpdateNotification_observer")
}
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
    /** 업로드한 프로필 이미지*/
      @objc dynamic var profileImageURLfirebase   : String    = ""
      /** 업로드한 프로필 이미지의 섬네일*/
      @objc dynamic var profileThumbURLfirebase   : String    = ""
    
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
        if profileThumbURLfirebase.isEmpty == false {
            return URL(string: profileThumbURLfirebase)
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
            data["profileImageURLgoogle"] = url.absoluteString
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
    
    func updateUserInfo(name:String, profileImageURL:URL?, profileImageThumbURL:URL?, isSetDefaultProfile:Bool, isSetGoogleProfile:Bool ,complete:@escaping(_ isSucess:Bool)->Void) {
        var data:[String:Any] = [
            "email" : email,
            "name" : name,
            "isDeleteProfileImage" : isSetDefaultProfile,
            "updateTimeIntervalSince1970" : Date().timeIntervalSince1970
        ]
        if let url = profileImageURL {
            data["profileImageURLfirebase"] = url.absoluteString
        }
        if let url = profileImageThumbURL {
            data["profileThumbURLfirebase"] = url.absoluteString
        }
        if isSetGoogleProfile {
            data["profileImageURLfirebase"] = ""
            data["profileThumbURLfirebase"] = ""
        }
        db.document(email).updateData(data) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(UserInfoModel.self, value: data, update: .all)
                try! realm.commitWrite()
                NotificationCenter.default.post(name: .profileUpdatedNotification, object: nil)
            }
            complete(error == nil)
        }
    }
}
