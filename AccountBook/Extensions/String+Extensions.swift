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
    /** firebase db : 공개용 data */
    public static let FSCollectionName_public_accountData:String = "account_data_public_TEST"
    #else
    /** firebase db : 사용자 정보 콜랙션 */
    public static let FSCollectionName_user:String = "users"
    /** firebase db : private 저장 data */
    public static let FSCollectionName_accountData:String = "accounts_data"
    /** firebase db : 공개용 data */
    public static let FSCollectionName_public_accountData:String = "account_data_public"
    #endif
    
    /** firebase db : 태그 */
    public static let FSCollectionName_accounts_tag:String = "tags"
   
    /** firebase db : 수입, 지출 */
    public static let FSCollectionName_accounts_income:String = "income"
}


extension String {
    func dateValue(format:String)->Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}
