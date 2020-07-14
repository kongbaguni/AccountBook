//
//  UserDefaut.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/14.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import GoogleSignIn
import Firebase
struct AuthData {
    let accessToken:String
    let idToken:String
}
extension UserDefaults {
    var authData:AuthData? {
        set {
            if let auth = newValue {
                set(auth.accessToken, forKey: "accessToken")
                set(auth.idToken, forKey: "idToken")
            } else {
                for key in ["accessToken","idToken"] {
                    removeObject(forKey: key)
                }
            }
        }
        get {
            if let accessToken = string(forKey: "accessToken"),
                let idToken = string(forKey: "idToken") {
                return AuthData(accessToken: accessToken, idToken: idToken)
            }
            return nil
        }
    }
}
