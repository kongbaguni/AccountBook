//
//  SigninWithGoogleId.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import GoogleSignIn
import Firebase
import SwiftUI

class SigninWithGoogleId: NSObject {
    override init() {
        super.init()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }
    func sign(viewController:UIViewController?) {
        if let vc = viewController {
            GIDSignIn.sharedInstance()?.presentingViewController = vc
            GIDSignIn.sharedInstance()?.signIn()
        } else {
            debugPrint("viewController is nil")
        }
    }
}

extension SigninWithGoogleId : GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let authentication = user.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) {(authResult, error) in
            authResult?.joinIfNeed(complete: { (isSucess) in
                debugPrint("sign in sucess")
                // Create the SwiftUI view that provides the window contents.
                let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                if let windowScenedelegate = scene?.delegate as? SceneDelegate {
                   let window = UIWindow(windowScene: scene!)
                   window.rootViewController = UIHostingController(rootView:MainTabView())
                   windowScenedelegate.window = window
                   window.makeKeyAndVisible()
                }
            })
        }
    }
}
