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
}
struct MakeIncomeView: View {
    @State var name:String = ""
    @State var value:String = ""
    @State var tags:String = ""
    //    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let isIncome:Bool
    let incomeId:String?
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
        }
    }
    
    var body: some View {
        List {
            HStack {
                Text("name")
                RoundedTextField(title: "name", text: $name, keyboardType: .default)
            }.padding(20)
            HStack {
                Text("price")
                RoundedTextField(title: "price", text: $value, keyboardType: .numberPad)
                
            }.padding(20)
            HStack {
                Text("tags")
                RoundedTextField(title: "tags", text: $tags, keyboardType: .default)
            }.padding(20)
        }
            .onAppear {
                print("MakeIncomeView did appear")
                self.loadData()
        }
        .onDisappear{
            self.save()
        }
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
            coordinate2D: nil) { (isSucess) in
                NotificationCenter.default.post(name: .incomeDataDidUpdated, object: nil)
        }
    }
}

struct MakeIncomeView_Previews: PreviewProvider {
    static var previews: some View {
        MakeIncomeView(incomeId: nil)
    }
}
