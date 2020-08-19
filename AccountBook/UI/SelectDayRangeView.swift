//
//  SelectDayRangeView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI

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
