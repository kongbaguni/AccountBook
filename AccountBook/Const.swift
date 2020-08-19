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
    
    enum DayRangeType:String, CaseIterable {
        case daily = "daily"
        case monthly = "monthly"
    }
    
    static var dayRangeSelection:DayRangeType? {
        set {
            print(newValue?.rawValue ?? "unSet")
            if let value = newValue?.rawValue {
                UserDefaults.standard.set(value, forKey: "dayRangeSelection")
            }
        }
        get {
            if let value = UserDefaults.standard.string(forKey: "dayRangeSelection") {
                return DayRangeType(rawValue: value)
            }
            return DayRangeType.allCases.first
        }
    }
}
