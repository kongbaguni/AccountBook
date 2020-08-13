//
//  IncomeListView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/31.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift



struct IncomeListView: View {
    @State var listData:Results<IncomeModel> = try! Realm().objects(IncomeModel.self).sorted(byKeyPath: "regTimeIntervalSince1970").filter("creatorEmail = %@",loginedEmail)
    var sum:Float {
        let sum:Float = listData.sum(ofProperty: "value")
        return sum
    }
    
    var sumStr:String {
        return sum.currencyFormatString
    }
    
    var countOfIncome:Int {
        return listData.filter("value > 0").count
    }
    
    var countOfExpenditure:Int {
        return listData.filter("value < 0").count
    }
    
    var body: some View {
        VStack {
            List(listData, id:\.id) { model in
                NavigationLink(destination: MakeIncomeView(incomeId: model.id, isIncome: model.value > 0)) {
                    IncomeExpenditureRowView(data:model)
                }
            }
            HStack {
                VStack {
                    HStack {
                        Text("income")
                        Text("\(countOfIncome)").foregroundColor(.green).italic()
                    }
                    HStack {
                        Text("expenditure")
                        Text("\(countOfExpenditure)").foregroundColor(.green).italic()
                    }
                }.padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                Spacer()
                Text(sumStr)
                    .italic()
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .foregroundColor(sum < 0 ? .red : .blue)
            }
            HStack {
                NavigationLink(destination:
                    MakeIncomeView(incomeId: nil)
                ) {
                    Text("income").font(.title)
                }
                NavigationLink(destination:
                    MakeIncomeView(incomeId: nil, isIncome: false)
                ) {
                    Text("expenditure").font(.title)
                }
            }
        }
        .onAppear {
            IncomeModel.sync { (isSucess) in
                self.loadData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .incomeDataDidUpdated)) { (obj) in
            self.loadData()
        }
    }
    
    func loadData() {
        listData = try! Realm().objects(IncomeModel.self).sorted(byKeyPath: "regTimeIntervalSince1970").filter("creatorEmail = %@",loginedEmail)
    }
}

struct IncomeListView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeListView()
    }
}
