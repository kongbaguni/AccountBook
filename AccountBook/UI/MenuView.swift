//
//  MenuView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/08.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import FirebaseAuth

import RealmSwift

struct MenuView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isMonthly:Bool = false
    
    @State var isDayly:Bool = false

   
    
      var body: some View {
        List {
            Section(header: Text("")) {
                NavigationLink(destination: ProfileSettingView()) {
                    ProfileView()
                }
            }
            Section(header: Text("select period")) {
                NavigationLink(destination: SelectDayRangeView()) {
                    Text(Consts.dayRangeSelection.stringValue)
                }
            }
            Section(header: Text("")) {
                Button(action: {
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        print(error.localizedDescription)
                        return
                    }
                    
                    self.presentationMode.wrappedValue.dismiss()
                    UserDefaults.standard.authData = nil
                    LoginView().changeThisView()
                }) {
                    Text("Logout")
                }
            }
        }
        .navigationBarTitle("menu")
        .listStyle(GroupedListStyle())
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
