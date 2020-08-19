//
//  SelectDayRangeView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
extension Notification.Name {
    /** 보여주는 날자 범의(일간? 월간? 연간?)  선택 완료*/
    static let selectDayRangeDidChange = Notification.Name("selectDayRangeDidChange_observer")
}
struct SelectDayRangeView: View {
    let options = Consts.DayRangeType.allCases
    
    @State var optionSelect:Consts.DayRangeType? = Consts.dayRangeSelection

    var body: some View {
        List( selection: $optionSelect) {
            Section(header: Text("")) {
                ForEach(options, id: \.self) { option in
                    Text(option.stringValue)
                }
            }
        }
        .environment(\.editMode, .constant(EditMode.active))
        .onReceive([optionSelect].publisher) { (output) in
            print(output ?? "선택없음")
            if output != nil {
                Consts.dayRangeSelection = output ?? Consts.DayRangeType.daily
                NotificationCenter.default.post(name:.selectDayRangeDidChange, object:nil)
            } else {
                self.optionSelect = Consts.dayRangeSelection
            }
        }
        .navigationBarTitle("select period")
    }
}

struct SelectDayRangeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDayRangeView()
    }
}
