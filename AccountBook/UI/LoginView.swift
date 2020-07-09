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
            ButtonView(image: Image("google"), title: "Sign in with GoogleID".localized) {
                
                self.signInWithGoogle.sign(viewController: self.rootViewController)
            }
            ButtonView(image: Image("apple"), title: "Sign in with Apple".localized) {
                self.signInWithApple.startSignInWithAppleFlow()
            }
                        
            Image("narui").resizable().scaledToFit().frame(width: 300, height: 25, alignment: .center)
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
