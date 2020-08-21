//
//  TodayNavigationView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/08.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import HorizonCalendar
extension Notification.Name {
    /** 날자 선택 바 갱신됨 */
    static let todaySelectorDidUpdated = Notification.Name("todaySelectorDidUPdated_observer")
}

struct TodayNavigationView: View {
    @State var isActive:Bool = false
    @State var dayBefore:Int = 0 {
        didSet {
            NotificationCenter.default.post(name:.todaySelectorDidUpdated, object:dayBefore)
        }
    }
    
    var dayString:String {
        switch Consts.dayRangeSelection {
        case .daily:
            return Date.getMidnightTime(beforeDay:dayBefore).formatedString(format:"yyyy M d")
        case .weakly :
            var str = Date.getMidnightTime(beforeWeak:dayBefore).formatedString(format: "yyyy M d")
            str.append(" ~ \(Date.getMidnightTime(beforeWeak:dayBefore-1).formatedString(format: "M d"))")
            return str
        case .monthly:
            return Date.getMidnightTime(beforeMonth:dayBefore).formatedString(format:"yyyy M")
        case .yearly:
            return Date.getMidnightTime(beforeYear:dayBefore).formatedString(format:"yyyy")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        self.dayBefore += 1
                    }) {
                        Text("<").padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    }
                    Button(action: {
                        self.dayBefore = 0
                    }) {
                        Text(dayString).font(.headline)
                    }.disabled(dayBefore == 0)
                    Button(action: {
                        self.dayBefore -= 1
                    }) {
                        Text(">").padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    }.disabled(dayBefore == 0)
                }
                IncomeListView(beforeDay:dayBefore)
            }
            .navigationBarTitle(Consts.dayRangeSelection.textValue)
            .navigationBarItems(trailing:
                 NavigationLink(
                    destination: MenuView(),
                    isActive: $isActive,
                    label: {
                        Image("menu")
                })
            )
            .onReceive(NotificationCenter.default.publisher(for: .selectDayRangeDidChange)) { (obj) in
                self.dayBefore = 0
            }
        }
    }
}

struct TodayNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["en", "kr"], id: \.self) { id in
            TodayNavigationView()
                .environment(\.locale, .init(identifier: id))
        }
    }
}
