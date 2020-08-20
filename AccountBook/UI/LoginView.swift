//
//  LoginView.swift
//  AnyReview
//
//  Created by Changyul Seo on 2020/06/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    let signInWithApple = SigninWithApple()
    let signInWithGoogle = SigninWithGoogleId()
    @State var buttonDisabled:Bool = false
    var body: some View {
        VStack {
            TitleView()
            Spacer()
            ButtonView(image: Image("google"), title: Text("Sign in with GoogleID")) {
                
                self.signInWithGoogle.sign(viewController: self.rootViewController)
            }.disabled(buttonDisabled)
            ButtonView(image: Image("apple"), title: Text("Sign in with Apple")) {
                self.signInWithApple.startSignInWithAppleFlow()
            }.disabled(buttonDisabled)
                        
            Image("narui").resizable().scaledToFit().frame(width: 300, height: 25, alignment: .center)
            
        }.onReceive(NotificationCenter.default.publisher(for: .logoutDBwillDeleteNotification)) { (out) in
            self.buttonDisabled = true
        }.onReceive(NotificationCenter.default.publisher(for: .logoutDBdidDeletedNotification)) { (out) in
            self.buttonDisabled = false
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["en", "ko"], id: \.self) { id in
            LoginView()
                .environment(\.locale, .init(identifier: id))
        }
    }
}
