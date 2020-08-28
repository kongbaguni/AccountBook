//
//  Date+extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/10.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
extension Date {
    var simpleFormatStringValue:String {
        DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .short)
    }
    
    /** 지금 시각 기준 상대 시각 표시.*/
    var relativeTimeStringValue:String {
        let interval = Date().timeIntervalSince1970 - timeIntervalSince1970
        if interval < 60 {
            return "just now"
        }
        
        if interval < 60 * 60 {
            let m = "\(Int(interval / 60))"
            return String(format: "%@ minutes ago", m)
        }
        
        if interval < 60 * 60 * 24 {
            let h = "\(Int(interval / (60 * 60)))"
            return String(format: "%@ hour ago", h)
        }
        
        if interval < 60 * 60 * 24 * 2 {
            return "Yesterday"
        }
        
        if interval < 60 * 60 * 24 * 3 {
            return "Day before yesterday"
        }
        
        if interval < 60 * 60 * 24 * 30 {
            let h = "\(Int(interval / (60 * 60 * 24)))"
            return String(format: "%@ days ago", h)
        }
        
        return DateFormatter.localizedString(from: self, dateStyle: .long, timeStyle: .none)
    }
    
    func formatedString(format:String)->String {
        let f = DateFormatter()
        f.dateFormat = format
        return f.string(from: self)
    }        
    
    static func getMidnightTime(before:Int, type:Consts.DayRangeType)->Date {
        switch type {
        case .daily:
            return Date.getMidnightTime(beforeDay: before)
        case .weakly:
            return Date.getMidnightTime(beforeWeak: before)
        case .monthly:
            return Date.getMidnightTime(beforeMonth: before)
        case .yearly:
            return Date.getMidnightTime(beforeYear: before)
        }
    }
    
    /** 오늘의  자정시각 구하기*/
    static var midnightTodayTime:Date {
        return Calendar.current.startOfDay(for: Date())
    }
    
    /** n일전 자정시각 구하기*/
    static func getMidnightTime(beforeDay:Int)->Date {
        let timeInterval = TimeInterval(60 * 60 * 24 * beforeDay) * -1
        return Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: timeInterval))
    }
    
    /** n달전 1일 자정시각 구하기*/
    static func getMidnightTime(beforeMonth:Int)->Date {
        let comm = Calendar.current.dateComponents([.month, .year], from: Date())
        let month = comm.month!
        let year = comm.year!        
        let format = "y_M"
        
        let date = "\(year)_\(month)".dateValue(format: format)!
        let interval = date.timeIntervalSince1970 - (Double(beforeMonth) * 31 * 60 * 60 * 24)
        let d2 = Date(timeIntervalSince1970:interval)
        print(d2.simpleFormatStringValue)
        let y2 = d2.formatedString(format: "y").integerValue
        let m2 = d2.formatedString(format: "M").integerValue
        
        let result = "\(y2)_\(m2)".dateValue(format: format)!
        print(result.simpleFormatStringValue)
        return result
    }
    /** n주전 월요일 자정시각 구하기*/
    static func getMidnightTime(beforeWeak:Int)->Date {
        let weekday = Calendar.current.dateComponents([.weekday], from: Date()).weekday! - 1
        return Date.getMidnightTime(beforeDay: weekday + (beforeWeak * 7))
    }
    
    /** n년전 1월1일 자정시각 구하기*/
    static func getMidnightTime(beforeYear:Int)->Date {
        let comp = Calendar.current.dateComponents([.year], from: Date())
        let year = comp.year!
        return "\(year - beforeYear)".dateValue(format:"y") ?? Date()
    }
    

}

