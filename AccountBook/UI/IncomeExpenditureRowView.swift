//
//  IncomeExpenditureRowView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/07.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift

struct IncomeExpenditureRowView: View {
    var name:String = "바나나우유"
    var price:Float = -1500
    var tags:String = "간식, 우유, 바나나"
    var creatorEmail:String = "kongbaguni@gmail.com"
    var regDt:Date = Date()
    var creator:UserInfoModel? {
        return try! Realm().object(ofType: UserInfoModel.self, forPrimaryKey: creatorEmail)
    }
    
    init(data:IncomeModel?) {
        if let d = data {
            setData(data: d)
        }
    }
    
    mutating func setData(data:IncomeModel) {
        name = data.name
        price = data.value
        tags = data.tags
        creatorEmail = data.creatorEmail
        regDt = data.regTime
    }
    
    var body: some View {
        HStack {
            Text(name).font(.title).fontWeight(.heavy).foregroundColor(Color("orangeColor")).padding(10)
            VStack {
                Text(price.currencyFormatString).foregroundColor(price > 0 ? .blue : .red)
                Text(tags).foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                Text(regDt.relativeTimeStringValue)
            }
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.orangeColor,lineWidth: 2))
        }
    }
}

struct IncomeExpenditureRowView_Previews: PreviewProvider {
    static var previews: some View {
        
        ForEach(["en", "ko"], id: \.self) { id in
            IncomeExpenditureRowView(data:nil)                       .environment(\.locale, .init(identifier: id))
        }
    }
}
