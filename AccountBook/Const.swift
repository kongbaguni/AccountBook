//
//  Const.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/07.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SwiftUI

struct Consts {
    static let PROFILE_THUMB_SIZE = CGSize(width: 100, height: 100)
    static let PROFILE_LARGE_SIZE = CGSize(width: 1000, height: 1000)
    
    enum DayRangeType:Int, CaseIterable {
        case daily = 0
        case weakly = 1
        case monthly = 2
        case yearly = 3
        
        var textValue:Text {
            if self == .daily {
                return Text("daily")
            }
            if self == .weakly {
                return Text("weakly")
            }
            if self == .monthly {
                return Text("monthly")
            }
            if self == .yearly {
                return Text("yearly")
            }
            return Text(" ")
        }
    }
    
    
    static var dayRangeSelection:DayRangeType {
        set {
            print(newValue.rawValue)
            let value = newValue.rawValue
            UserDefaults.standard.set(value, forKey: "dayRangeSelection")
        }
        
        get {
            let value = UserDefaults.standard.integer(forKey: "dayRangeSelection")
            if let type = DayRangeType(rawValue: value) {
                return type
            }
            return .daily
        }
    }
}
