//
//  MakeIncomeView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/07.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift
import CoreLocation

extension Notification.Name {
    static let incomeDataDidUpdated = Notification.Name("incomeDataDidUpdated_observer")
    static let incomeDataWillDelete = Notification.Name("incomeDataWillDelete_observer")
}

struct MakeIncomeView: View {
    @State var name:String = ""
    @State var value:String = ""
    @State var tags:String = ""
 
    @State var location:CLLocation? = nil
    
    @State var showDeleteAlert:Bool = false
    var isIncome:Bool
    let incomeId:String?
    
    @State var mapView = MapView()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var locationManager = LocationManager()
    
    var userLatitude: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
    }
    
    var userLongitude: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
    }
    
    var incomeModel:IncomeModel? {
        if let id = incomeId {
            return try! Realm().object(ofType: IncomeModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    init(incomeId:String?, isIncome:Bool?) {
        print("MakeIconView init \(incomeId ?? "new")")
        self.incomeId = incomeId
        self.isIncome = isIncome ?? true
        if let model = incomeModel {
            tags = model.tags
            self.isIncome = model.value > 0
        } else {
            editTags = ""
        }
        print(tags)
    }
    
    @State var isLoaded:Bool = false
    func loadData() {
        if isLoaded {
            return
        }
        isLoaded.toggle()
        if let model = incomeModel {
            mapView.location = CLLocation(latitude: model.latitude, longitude: model.longitude)
            name = model.name
            value = "\(Int(abs(model.value)))"
            tags = model.tagStringValue
            editTags = model.tags
        }
    }
        
    var body: some View {
        List {
            Section(header: Text(incomeId == nil ? "make" : "edit"), footer: Text("")) {
                NavigationLink(destination: MakeNameView(name: self.name, isIncome: self.isIncome)) {
                    HStack {
                        Text("name")
                        RoundedTextField(title: "name", text: $name, keyboardType: .default, onEditingChanged: {_ in }, onCommit: { })
                    }.padding(20)
                }
                NavigationLink(destination: MakePriceView(price: self.value, isIncome: self.isIncome     )) {
                    HStack {
                        Text("price")
                        RoundedTextField(title: "price", text: $value, keyboardType: .numberPad, onEditingChanged: {_ in }, onCommit: { })
                        
                    }.padding(20)
                }
                NavigationLink(destination: MakeTagView(tags:self.tags)) {
                    HStack {
                        Text("tags")
                        Text(tags).foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }.padding(20)
                }
            }
            Section(header: Text("location")) {
                mapView.frame(width: UIScreen.main.bounds.width - 30, height: 300, alignment: .center)
            }
            if incomeId != nil {
                Section(header: Text(""), footer: Text("")) {
                    Button(action: {
                        self.showDeleteAlert = true
                    }) {
                        Text("delete")
                    }.padding(20)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .alert(isPresented: $showDeleteAlert, content: { () -> Alert in
            return Alert(
                title: Text("delete"),
                message: Text("delete this?"),
                primaryButton: .default(Text("confirm"), action: {
                    if let id = self.incomeModel?.id {
                        self.presentationMode.wrappedValue.dismiss()
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .incomeDataWillDelete, object: id)
                        }
                    }
                }), secondaryButton: .cancel({
                    
                }))
        })
        .onAppear {
            print("MakeIncomeView did appear")
            self.loadData()
            if self.incomeId == nil {
                self.mapView.location = UserDefaults.standard.lastLocation
            }
        }
        .navigationBarItems(leading:
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("cancel")
            }
            ,trailing:
            Button(action: {
                self.save()
            }) {
                Text("save")
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: .makeTagsNotification), perform: { (obj) in
            if let list = obj.object as? [String] {
                var txt = ""
                for text in list {
                    if txt.isEmpty == false {
                        txt.append(",")
                    }
                    txt.append(text)
                }
                self.tags = txt
                editTags = txt  
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: .nameModifiedFromListNotification), perform: { (obj) in
            if let name = obj.object as? String {
                self.name = name
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: .priceModifiedFromListNotification), perform: { (obj) in
            if let price = obj.object as? String {
                self.value = price
            }                
        })
        .onReceive(NotificationCenter.default.publisher(for: .locationDidUpdateLocations), perform: { (out) in
            if let location = out.object as? CLLocation {
                if self.incomeId == nil {
                    self.location = location
                    self.mapView.location  = location
                }
            }
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(isIncome ? "income" : "expenditure"))
            
    }
    
    
    func save() {
        if self.name.isEmpty || self.value.isEmpty {
            return
        }
        let value = abs(self.value.floatValue)
        IncomeModel.create(
            id: self.incomeModel?.id,
            value: self.isIncome ? value : -value ,
            name: self.name,
            tags: self.tags,
            coordinate2D: location?.coordinate) { (isSucess,id) in
                NotificationCenter.default.post(name: .incomeDataDidUpdated, object: id)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

struct MakeIncomeView_Previews: PreviewProvider {
    static var previews: some View {
        MakeIncomeView(incomeId: nil, isIncome: false)
    }
}
