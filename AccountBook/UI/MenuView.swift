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

extension Notification.Name {
    static let logoutDBwillDeleteNotification = Notification.Name("logoutDBwillDeleteNotification_observer")
    static let logoutDBdidDeletedNotification = Notification.Name("logoutDBdidDeletedNotification_observer")
}

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
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                        NotificationCenter.default.post(name: .logoutDBwillDeleteNotification, object: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            let realm = try! Realm()
                            realm.beginWrite()
                            realm.deleteAll()
                            try! realm.commitWrite()
                            NotificationCenter.default.post(name: .logoutDBdidDeletedNotification, object: nil)
                        }
                    }
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
