//
//  View+Extensions.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/08.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SwiftUI
extension View {
    func changeThisView() {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        if let windowScenedelegate = scene?.delegate as? SceneDelegate {
            let window = UIWindow(windowScene: scene!)
            window.rootViewController = UIHostingController(rootView:self)
            windowScenedelegate.window = window
            window.makeKeyAndVisible()
        }
    }
    
    var rootViewController : UIViewController? {
        if let sceneDelegate = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.delegate as? SceneDelegate {
            return sceneDelegate.window?.rootViewController
        }
        return nil
    }
}
