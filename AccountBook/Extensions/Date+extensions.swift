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
    
    /** 오늘의  자정시각 구하기*/
    static var midnightTodayTime:Date {
        let format = "yyyyMMdd"
        return Date().formatedString(format: format).dateValue(format: format)!
    }
    
    /** n일전 자정시각 구하기*/
    static func getMidnightTime(beforeDay:Int)->Date {
        let format = "yyyyMMdd"
        let dayInterval:Double = Double(Date().timeIntervalSince1970) - Double(60 * 60 * 24 * beforeDay)
        let day = Date(timeIntervalSince1970: dayInterval)
        return day.formatedString(format: format).dateValue(format: format)!
    }
    
    /** n달전 1일 자정시각 구하기*/
    static func getMidnightTime(beforeMonth:Int)->Date {
        let year = Date().formatedString(format: "y").integerValue
        let month = Date().formatedString(format: "M").integerValue
        
        let y = beforeMonth / 12
        let m = beforeMonth % 12
        let str = "\(year - y)_\(month - m)"
        print(str)
        return str.dateValue(format: "y_M") ?? Date()
    }
    
    /** n년전 1월1일 자정시각 구하기*/
    static func getMidnightTime(beforeYear:Int)->Date {
        let year = Date().formatedString(format:"y").integerValue
        return "\(year - beforeYear)".dateValue(format:"y") ?? Date()
    }
    

}

