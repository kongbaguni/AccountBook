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
    /** 다국어 번역 지원 */
    var localized:String {
        let value = NSLocalizedString(self, comment:"")
        return value
    }
}


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
    public static let FSCollectionName_user:String = "AccountBook_user_TEST"
    #else
    /** firebase db : 사용자 정보 콜랙션 */
    public static let FSCollectionName_user:String = "AccountBook_user"
    #endif
}
