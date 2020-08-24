//
//  MakeNameView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/18.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift
import CoreLocation

extension Notification.Name {
    static let nameModifiedFromListNotification = Notification.Name("nameModifiredFromList_observer")
}

struct MakeNameView: View {
    fileprivate var nameValue:String = ""
    fileprivate var isIncome:Bool = false
    
    @State var name:String = ""
    @State var names:[String] = []
    
    var incomeId:String? = nil
    var incomeModel:IncomeModel? {
        if let id = incomeId {
            return try! Realm().object(ofType: IncomeModel.self, forPrimaryKey: id)
        }
        return nil
    }
    var location:CLLocation? {
        if let model = self.incomeModel {
            return CLLocation(latitude: model.latitude, longitude: model.longitude)
        }
        if let location = UserDefaults.standard.lastLocation {
            return location
        }
        return  nil
    }
    
    init(name:String, isIncome:Bool, incomeId:String?) {
        self.nameValue = name
        self.isIncome  = isIncome
        self.incomeId = incomeId
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
                        NotificationCenter.default.post(name: .nameModifiedFromListNotification, object: self.name) 
                    }) {
                        NotificationCenter.default.post(name: .nameModifiedFromListNotification, object: self.name)
                    }.padding(10)
                }
            }
            Section(header: Text(names.count == 0 ? "" : "Names previously entered")) {
                ForEach(names, id:\.self) { newName in
                    Button(action: {
                        self.name = newName
                        NotificationCenter.default.post(name: .nameModifiedFromListNotification, object: self.name)
                    }) {
                        Text(newName)
                    }
                }
            }
        }
        .navigationBarTitle(Text("edit name"))
        .listStyle(GroupedListStyle())
        .onAppear {
            self.name = self.nameValue
            self.loadNames()
        }
    }
    
    func loadNames() {
        var names = Set<String>()
        var list = try! Realm().objects(IncomeModel.self)
        if let location = self.location?.coordinate {
            let minlat = location.latitude - 0.005
            let maxlat = location.latitude + 0.005
            let minlng = location.longitude - 0.005
            let maxlng = location.longitude + 0.005
            list = list.filter("latitude > %@ && latitude < %@ && longitude > %@ && longitude < %@"
                ,minlat, maxlat, minlng, maxlng)
        }        
        if isIncome  {
            list = list.filter("value > %@", 0)
        } else {
            list = list.filter("value < %@", 0)
        }
        for model in list {
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
        MakeNameView(name: "하하하", isIncome: true, incomeId: nil)
    }
}
