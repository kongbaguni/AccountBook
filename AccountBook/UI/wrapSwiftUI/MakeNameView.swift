//
//  MakeNameView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/18.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift

extension Notification.Name {
    static let nameModifiedFromListNotification = Notification.Name("nameModifiredFromList_observer")
}

fileprivate var nameValue:String = ""
struct MakeNameView: View {
    @State var name:String = ""
    @State var names:[String] = []
    init(name:String) {
        nameValue = name
    }
    
    var body: some View {
        List {
            Section(header: Text("")) {
                HStack {
                    Text("name").padding(10)
                    RoundedTextField(
                        title: "name",
                        text: $name,
                        keyboardType: .default,
                        onEditingChanged: { (_) in
                    }) {
                        NotificationCenter.default.post(name: .nameModifiedFromListNotification, object: self.name)
                    }.padding(10)
                }
            }
            Section(header: Text("names")) {
                ForEach(names, id:\.self) { newName in
                    Button(action: {
                        self.name = newName
                        NotificationCenter.default.post(name: .nameModifiedFromListNotification, object: self.name)
                    }) {
                        Text(newName)
                    }
                }
            }
        }.onAppear {
            self.name = nameValue
            self.loadNames()
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text("edit name"))
    }
    
    func loadNames() {
        var names = Set<String>()
        for model in try! Realm().objects(IncomeModel.self) {
            let n = model.name.trimmingValue
            if n.isEmpty == false {
                names.insert(model.name)
            }
        }
        self.names = names.sorted()
    }
}

struct MakeNameView_Previews: PreviewProvider {
    static var previews: some View {
        MakeNameView(name: "하하하")
    }
}
