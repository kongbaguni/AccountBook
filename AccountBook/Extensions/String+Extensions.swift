//
//  String+Extensions.swift
//  AnyReview
//
//  Created by Changyul Seo on 2020/06/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import CryptoKit



extension String {
    var sha256:String {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }      
}

extension String {
    #if DEBUG
    /** firebase db : 사용자 정보 콜랙션 */
    public static let FSCollectionName_user:String = "users_TEST"
    /** firebase db : private 저장 data */
    public static let FSCollectionName_accountData:String = "accounts_data_TEST"
    /** firenase db : tag 정보 저장*/
    public static let FSCollectionName_tags:String = "accounts_tag_TEST"
    #else
    /** firebase db : 사용자 정보 콜랙션 */
    public static let FSCollectionName_user:String = "users"
    /** firebase db : private 저장 data */
    public static let FSCollectionName_accountData:String = "accounts_data"
    /** firenase db : tag 정보 저장*/
    public static let FSCollectionName_tags:String = "accounts_tag"
    #endif
    }


extension String {
    func dateValue(format:String)->Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }

    var floatValue:Float {
        return NSString(string: self).floatValue
    }
    
    var integerValue:Int {
        return NSString(string: self).integerValue
    }
    
    /** 앞뒤로 스페이스 제거*/
    var trimmingValue:String {
        return trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }
}
