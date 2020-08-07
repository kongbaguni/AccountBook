//
//  IncomeListView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/31.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift

fileprivate var list:Results<IncomeModel> {
    return try! Realm().objects(IncomeModel.self)
}

struct IncomeListView: View {
    
    var body: some View {
        VStack {
            List(list, id:\.id) { model in
                IncomeExpenditureRowView(data:model)
            }
            NavigationLink(destination:
                MakeIncomeView(incomeId: nil)
            ) {
                Text("Make New")
            }
        }
    }
}

struct IncomeListView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeListView()
    }
}
