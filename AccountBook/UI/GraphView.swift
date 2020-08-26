//
//  GraphView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/26.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift

fileprivate let HEIGHT:CGFloat = 150

struct GraphView: View {
    struct Data {
        let id:String = UUID().uuidString
        let value:Float
        let height:CGFloat
        let date:Date
    }
    
    @State var datas:[Data] = []
    
    @State var before = 0
    
    var beforeDays:[Int] {
        var result:[Int] = []
        for a in before..<before+7 {
            result.append(a)
        }
        return result.reversed()
    }

    func loadData() {
        datas.removeAll()
        for d in beforeDays {
            let count = getCount(beforeDay: d)
            let height = getHeight(beforeDay: d)
            let date = getDate(beforeDay: d)
            let data = Data(value: count, height: height, date: date)
            datas.append(data)
        }
    }
    
    func getDate(beforeDay:Int)->Date {
        return Date.getMidnightTime(before: beforeDay, type: Consts.dayRangeSelection)
    }
    
    func getCount(beforeDay:Int)->Float {
        let t1:Date = Date.getMidnightTime(before: beforeDay, type: Consts.dayRangeSelection)
        let t2:Date = Date.getMidnightTime(before: beforeDay-1, type: Consts.dayRangeSelection)
        
        let realm = try! Realm()
        let list = realm.objects(IncomeModel.self).filter("regTimeIntervalSince1970 > %@ && regTimeIntervalSince1970 <= %@", t1.timeIntervalSince1970, t2.timeIntervalSince1970)
        let sum:Float  = list.sum(ofProperty: "value")
        return sum
    }
    
    func getHeight(beforeDay:Int)->CGFloat {
        let max = HEIGHT / 2 - 20
        let sum = getCount(beforeDay: beforeDay)
        let result = CGFloat(abs(sum)) / 10000 + 10
        return result > max ? max : result
    }
    
    init(before:Int) {
        self.before = before
    }
    
    var dayFormatString:String {
        switch Consts.dayRangeSelection {
        case .daily, .weakly:
            return "M d"
        case .monthly:
            return "M"
        case .yearly:
            return "y"
        }
    }
    
    var body: some View {
        HStack {
            ForEach(datas, id:\.id) { d in
                VStack {
                    Capsule()
                        .foregroundColor(.blue)
                        .frame(width: 10,
                               height: d.value > 0 ? d.height : 0,
                               alignment: .center)
                    Text(d.date.formatedString(format: self.dayFormatString))
                        .font(.system(size: 8))
                    Capsule()
                        .foregroundColor(.red)
                        .frame(width: 10,
                               height: d.value < 0 ? d.height : 0,
                               alignment: .center)

                }.frame(width: (UIScreen.main.bounds.width - 30) / CGFloat(self.beforeDays.count + 1),
                        height: HEIGHT,
                        alignment: .center)
            }
        }
        .frame(width: nil, height: HEIGHT, alignment: .center)
        .onAppear {
            self.loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .incomeDataDidUpdated)) { (obj) in
            self.loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .todaySelectorDidUpdated)) { (obj) in
            if let day = obj.object as? Int {
                self.before = day
            }
            self.loadData()
        }
    }
    
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(before: 0)
    }
}
