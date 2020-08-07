//
//  MakeIncomeView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/07.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift

struct MakeIncomeView: View {
    @State var name:String = ""
    @State var value:String = ""
    @State var tags:String = ""
    
    var incomeId:String? = nil
    var incomeModel:IncomeModel? {
        if let id = incomeId {
            return try! Realm().object(ofType: IncomeModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    init(incomeId:String?) {
        self.incomeId = incomeId
        
        if let model = incomeModel {
            name = model.name
            value = "\(model.value)"
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
    }
}

struct MakeIncomeView_Previews: PreviewProvider {
    static var previews: some View {
        MakeIncomeView(incomeId: nil)
    }
}
