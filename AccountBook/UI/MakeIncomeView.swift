//
//  MakeIncomeView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/07.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift
extension Notification.Name {
    static let incomeDataDidUpdated = Notification.Name("incomeDataDidUpdated_observer")
    static let incomeDataWillDelete = Notification.Name("incomeDataWillDelete_observer")
}
struct MakeIncomeView: View {
    @State var name:String = ""
    @State var value:String = ""
    @State var tags:String = ""
 
    let isIncome:Bool
    let incomeId:String?
    
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var incomeModel:IncomeModel? {
        if let id = incomeId {
            return try! Realm().object(ofType: IncomeModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    init(incomeId:String?, isIncome:Bool = true) {
        print("MakeIconView init \(incomeId ?? "new")")
        self.incomeId = incomeId
        self.isIncome = isIncome
        if let model = incomeModel {
            tags = model.tags
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
            name = model.name
            value = "\(Int(abs(model.value)))"
            tags = model.tags
            editTags = model.tags
        }
    }
        
    var body: some View {
        List {
            HStack {
                Text("name")
                RoundedTextField(title: "name", text: $name, keyboardType: .default, onEditingChanged: {_ in }, onCommit: { })
            }.padding(20)
            HStack {
                Text("price")
                RoundedTextField(title: "price", text: $value, keyboardType: .numberPad, onEditingChanged: {_ in }, onCommit: { })
                
            }.padding(20)
            NavigationLink(destination: MakeTagView(tags:self.tags)) {
                HStack {
                    Text("tags")
                    Text(tags)
                }.padding(20)
            }
            if incomeId != nil {
                Button(action: {
                    if let id = self.incomeModel?.id {
                        self.presentationMode.wrappedValue.dismiss()
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .incomeDataWillDelete, object: id)
                        }
                    }
                }) {
                    Text("delete")
                }.padding(20)
                
            }
        }
        .onAppear {
            print("MakeIncomeView did appear")
            self.loadData()
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
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(isIncome ? "income" : "expenditure"))
    }
    
    
    func save() {
        if self.name.isEmpty || self.value.isEmpty {
            return
        }
        let value = abs(self.value.floatValue)
        let newId = IncomeModel.create(
            id: self.incomeModel?.id,
            value: self.isIncome ? value : -value ,
            name: self.name,
            tags: self.tags,
            coordinate2D: nil) { (isSucess) in
                NotificationCenter.default.post(name: .incomeDataDidUpdated, object: nil)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

struct MakeIncomeView_Previews: PreviewProvider {
    static var previews: some View {
        MakeIncomeView(incomeId: nil)
    }
}
