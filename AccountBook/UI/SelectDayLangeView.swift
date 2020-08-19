//
//  SelectDayLangeView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI

struct SelectDayLangeView: View {
    let options = Consts.DayRangeType.allCases
    
    @State var optionSelect:Consts.DayRangeType? = Consts.dayRangeSelection

    var body: some View {
        List( selection: $optionSelect) {
            Section(header: Text("")) {
                ForEach(options, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
        }
        .environment(\.editMode, .constant(EditMode.active))
        .onReceive([optionSelect].publisher) { (output) in
            print(output ?? "선택없음")
            if output != nil {
                Consts.dayRangeSelection = output
            }
        }
        .navigationBarTitle("select option")
    }
}

struct SelectDayLangeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDayLangeView()
    }
}
