//
//  SUHorizonCalendarView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/09.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import UIKit
import HorizonCalendar
extension DateComponents {
    static func date(year:Int, month:Int,day:Int)->DateComponents {
        return DateComponents(year: year, month: month, day: day)
    }
}

struct SUHorizonCalendarView : UIViewRepresentable {
    let identifier:Calendar.Identifier
    let startDate:DateComponents
    let endDate:DateComponents
    
    func makeCoordinator() -> () {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> CalendarView {
        func makeContent() -> CalendarViewContent {
            let calendar = Calendar(identifier: identifier)
            
            let startDate = calendar.date(from: self.startDate)!
            let endDate = calendar.date(from: self.endDate)!

          return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions()))
        }
        return CalendarView(initialContent: makeContent())
       
    }
    
    func updateUIView(_ uiView: CalendarView, context: Context) {
        uiView.layoutSubviews()
    }
}

struct SUHorizonCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        SUHorizonCalendarView(identifier: .gregorian,
                              startDate: .date(year: 2020, month: 1, day: 1),
                              endDate: .date(year: 2020, month: 12, day: 31))
    }
}
