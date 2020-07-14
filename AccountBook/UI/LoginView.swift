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
    
    var body: some View {
        VStack {
            TitleView()
            Spacer()
            ButtonView(image: Image("google"), title: Text("Sign in with GoogleID")) {
                
                self.signInWithGoogle.sign(viewController: self.rootViewController)
            }
            ButtonView(image: Image("apple"), title: Text("Sign in with Apple")) {
                self.signInWithApple.startSignInWithAppleFlow()
            }
                        
            Image("narui").resizable().scaledToFit().frame(width: 300, height: 25, alignment: .center)
            
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
