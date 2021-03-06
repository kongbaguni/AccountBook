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
    @State var beforeDay:Int = 0
    @State var year:Int = Date().formatedString(format: "y").integerValue
    @State var month:Int? = nil
    @State var day:Int? = nil
    
    var t1:Date { Date.getMidnightTime(before: self.beforeDay, type: Consts.dayRangeSelection) }
    var t2:Date { Date.getMidnightTime(before: self.beforeDay-1, type: Consts.dayRangeSelection) }
    
    var listData:Results<IncomeModel> {
        print("""
            _________________________________
            \(t1.simpleFormatStringValue) to \(t2.simpleFormatStringValue)
            \(t1.timeIntervalSince1970) ~ \(t2.timeIntervalSince1970)
            ---------------------------------
            """
        )
        return try! Realm().objects(IncomeModel.self)
            .sorted(byKeyPath: "regTimeIntervalSince1970")        
            .filter("creatorEmail == %@ && %@ <= regTimeIntervalSince1970 && regTimeIntervalSince1970 < %@"
                , loginedEmail
                ,t1.timeIntervalSince1970
                ,t2.timeIntervalSince1970
        )        
    }
    
    init(beforeDay:Int = 0) {
        self.beforeDay = beforeDay
        loadData()
    }
    
    /** 수입 리스트*/
    @State var list:[String] = []
    /** 지출 리스트*/
    @State var eList:[String] = []
    
    var sum:Float {
        let sum:Float = listData.sum(ofProperty: "value")
        return sum
    }
    
    var incomeSum:Float {
        let sum:Float = listData.filter("value > 0").sum(ofProperty: "value")
        return sum
    }
    
    var expenditureSum:Float {
        let sum:Float = listData.filter("value < 0").sum(ofProperty: "value")
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
    
    func model(_ id:String)->IncomeModel? {
        try! Realm().object(ofType: IncomeModel .self, forPrimaryKey: id)
    }
    
    var dateSelect:MakeIncomeView.DateSelect? {
        if beforeDay == 0 {
            return nil
        }
        switch Consts.dayRangeSelection {
        case .daily:
            return MakeIncomeView.DateSelect(year: t1.formatedString(format: "y").integerValue,
                month: t1.formatedString(format: "M").integerValue,
                day: t1.formatedString(format: "d").integerValue)
        case .weakly:
            return MakeIncomeView.DateSelect(year: t1.formatedString(format: "y").integerValue,
                month: t1.formatedString(format: "M").integerValue,
                day: t1.formatedString(format: "d").integerValue)
        case .monthly:
            return MakeIncomeView.DateSelect(year: t1.formatedString(format: "y").integerValue,
                month: t1.formatedString(format: "M").integerValue,
                day: nil)
        case .yearly:
            return MakeIncomeView.DateSelect(year: t1.formatedString(format: "y").integerValue,
                month: nil,
                day: nil)
        }
    }
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("graph")) {
                    GraphView(before: self.beforeDay)
                }
                if list.count > 0 {
                    Section(header: Text("income")) {
                        ForEach(list, id:\.self) { id in
                            NavigationLink(destination: MakeIncomeView(incomeId: id, isIncome: nil)) {
                                IncomeExpenditureRowView(data: self.model(id)?.data)
                            }
                        }
                    }
                }
                if eList.count > 0 {
                    Section(header: Text("expenditure")) {
                        ForEach(eList, id:\.self) { id in
                            NavigationLink(destination: MakeIncomeView(incomeId: id, isIncome: nil)) {
                                IncomeExpenditureRowView(data: self.model(id)?.data)
                            }
                        }
                    }
                    
                }
                if list.count == 0 && eList.count == 0 {
                    Text("empty income or expenture").padding(20).foregroundColor(Color.orangeColor)
                }
            }.listStyle(GroupedListStyle())
            HStack {
                VStack {
                    HStack {
                        Text("income")
                        Text("\(countOfIncome)").foregroundColor(.green).italic()
                        Spacer()
                        Text(incomeSum.currencyFormatString).foregroundColor(.blue).italic()
                    }
                    HStack {
                        Text("expenditure")
                        Text("\(countOfExpenditure)").foregroundColor(.green).italic()
                        Spacer()
                        Text(expenditureSum.currencyFormatString).foregroundColor(.red).italic()
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
                    MakeIncomeView(incomeId: nil, isIncome: true, dateSelect: self.dateSelect)
                ) {
                    Text("income").font(.title)
                }
                NavigationLink(destination:
                    MakeIncomeView(incomeId: nil, isIncome: false, dateSelect: self.dateSelect)
                ) {
                    Text("expenditure").font(.title)
                }
            }
        }
        .onAppear {
            IncomeModel.sync { (isSucess) in
                self.loadData()
            }
            
            if self.beforeDay > 0 {
                switch Consts.dayRangeSelection {
                case .daily:
                    
                    break
                case .weakly:
                    break
                case .monthly:
                    break
                case .yearly:
                    break
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .incomeDataDidUpdated)) { (obj) in
            self.loadData(updateId: obj.object as? String)
            if obj.object != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) + .milliseconds(100)) {
                    self.loadData()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .incomeDataWillDelete)) { (obj) in
            if let id = obj.object as? String {
                if let model = try! Realm().object(ofType: IncomeModel.self, forPrimaryKey: id) {
                    model.delete { (isSucess) in
                        self.loadData()
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .todaySelectorDidUpdated)) { (obj) in
            if let day = obj.object as? Int {
                self.beforeDay = day
                self.loadData()
            }
        }
    }
    
    func loadData(updateId:String? = nil) {
        list.removeAll()
        eList.removeAll()
        print("listData.count : \(listData.count)")
        if listData.count > 0 {
            for item in listData {
                if item.value < 0 {
                    eList.append(item.id)
                } else {
                    list.append(item.id)
                }
                print("\(item.name) : \(item.regTime.simpleFormatStringValue)")
            }
            
        }
    }
}

struct IncomeListView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeListView(beforeDay:0)
    }
}
