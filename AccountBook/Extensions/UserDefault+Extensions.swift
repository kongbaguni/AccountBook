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
import CoreLocation

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
    
    var lastLocation:CLLocation? {
        set {
            if let value = newValue {
                set(value.coordinate.latitude, forKey: "lastLocationLat")
                set(value.coordinate.longitude, forKey: "lastLocationLong")
            } else {
                set(nil, forKey:"lastLocationLat")
                set(nil, forKey:"lastLocationLong")
            }
        }
        get {
            let lat = double(forKey: "lastLocationLat")
            let long = double(forKey: "lastLocationLong")
            if lat == 0 && long == 0 {
                return nil
            }
            return CLLocation(latitude: lat, longitude: long)
        }
    }
    
    
    var isRequestHealthAuth:Bool {
        set {
            set(newValue, forKey: "isRequestHealthAuth")
        }
        get {
            bool(forKey: "isRequestHealthAuth")
        }
    }
}
