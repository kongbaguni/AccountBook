//
//  AuthDataResult+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/04.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import FirebaseAuth
import RealmSwift

extension AuthDataResult {
    var name:String? {
        return additionalUserInfo?.profile?["name"] as? String ?? email?.components(separatedBy: "@").first
    }
    var email:String? {
        return additionalUserInfo?.profile?["email"] as? String
    }
    
    var pictureURL:String? {
        return additionalUserInfo?.profile?["picture"] as? String
    }
    
    func getIsJoin(complete:@escaping(_ isJoined:Bool)->Void) {
        if let email = self.email {
            loginedEmail = email
            UserInfoModel.getUserInfo(email: email) { (isSucess) in
                complete(isSucess)
            }
        } else {
            complete(false)
        }
    }
    
    func join(complete:@escaping(_ isSucess:Bool)->Void) {
        if let userInfo = self.additionalUserInfo,
            let profile = userInfo.profile {
            let name = self.name ?? ""
            let profileUrl = profile["picture"] as? String  ?? ""
            UserDefaults.standard.set(profileUrl, forKey: "profileTemp")
            if let email = profile["email"] as? String {
                UserInfoModel.createUserInfo(
                    email: email,
                    name: name,
                    uploadProfileImageURL: URL(string: profileUrl)) { (isSucess) in
                        complete(isSucess)
                }
            }
        }
    }
    
    func joinIfNeed(complete:@escaping(_ isSucess:Bool)->Void) {
        getIsJoin { (isSucess) in
            if isSucess {
                complete(true)
            } else {
                self.join { (isSucess) in
                    complete(isSucess)
                }
            }
        }
    }
}
