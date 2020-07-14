//
//  MenuView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/08.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import FirebaseAuth

struct MenuView: View {
    var body: some View {
        List {
            NavigationLink(destination: ProfileSettingView()) {
                 ProfileView()
            }
            Button(action: {
                do {
                    try Auth.auth().signOut()
                } catch {
                    print(error.localizedDescription)
                    return
                }
                UserDefaults.standard.authData = nil
                LoginView().changeThisView()
            }) {
                Text("Logout")
            }
        }.navigationBarTitle("menu")
        
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
