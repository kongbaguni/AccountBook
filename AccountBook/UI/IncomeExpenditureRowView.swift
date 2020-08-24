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
    @State var name:String = "....."
    @State var price:Float = 0
    @State var creatorEmail:String = " "
    @State var regDt:Date = Date()
    @State var isNew:Bool = false
    @State var tags:String = "....."
    
    var creator:UserInfoModel? {
        return try! Realm().object(ofType: UserInfoModel.self, forPrimaryKey: creatorEmail)
    }
    var data:IncomeModel.Data? = nil
    init(data:IncomeModel.Data?) {
        self.data = data
    }
    
    func loadData() {
        if let data = data {
            name = data.data?.name ?? ""
            price = data.data?.value ?? 0
            tags = data.data?.tagStringValue ?? ""
            creatorEmail = data.data?.creatorEmail ?? loginedEmail
            regDt = data.data?.regTime ?? Date()
            isNew = data.data?.isNew ?? false
        }
    }
    
    var tagIsEmpty:Bool {
         return tags.trimmingValue.isEmpty == true
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(name).font(.title).fontWeight(.heavy).foregroundColor(Color("orangeColor")).padding(10)
                Spacer()
                Text(price.currencyFormatString)
                    .italic()
                    .foregroundColor(price > 0 ? .blue : .red)
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
            
            HStack {
                Text(regDt.simpleFormatStringValue)
                    .font(.footnote)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: tagIsEmpty ? 10 : 0, trailing: 10))
                Spacer()
            }

            if tagIsEmpty == false {
                HStack {
                    Image("tagIcon")
                    Text(tags)
                        .foregroundColor(.green)
                    Spacer()
                }.padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0))
            }
        }
        .background(Rectangle().stroke(isNew ? Color.buttonStrockColor : Color.clear, lineWidth: 1))
        .onAppear {
            self.loadData()
        }.onReceive(NotificationCenter.default.publisher(for: .incomeDataDidUpdated)) { (output) in
            if output.object as? String == self.data?.id {
                self.loadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.loadData()
                }
            }
        }
        
    }
}

struct IncomeExpenditureRowView_Previews: PreviewProvider {
    static var previews: some View {
        
        ForEach(["en", "ko"], id: \.self) { id in
            IncomeExpenditureRowView(data:nil)
                .environment(\.locale, .init(identifier: id))
        }
    }
}
