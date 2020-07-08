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
            ProfileView()
            Button(action: {
                do {
                    try Auth.auth().signOut()
                } catch {
                    print(error.localizedDescription)
                    return
                }
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
