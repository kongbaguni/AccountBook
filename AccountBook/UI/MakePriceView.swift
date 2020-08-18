//
//  MakePriceView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/18.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift
extension Notification.Name {
    static let priceModifiedFromListNotification = Notification.Name(rawValue: "priceTagsNotification_observer")
}

struct MakePriceView: View {
    fileprivate var priceValue:String = ""
    fileprivate var isIncome:Bool = false
    
    @State var prices:[String] = []
    @State var price:String = ""
    
    init(price:String, isIncome:Bool) {
        self.priceValue = price
        self.isIncome  = isIncome
    }
    
    var body: some View {
        List {
            Section(header:Text("")) {
                HStack  {
                    Text("price").padding(10)
                    RoundedTextField(title: "price", text: $price, keyboardType: .numberPad, onEditingChanged: { (_) in
                        NotificationCenter.default.post(name: .priceModifiedFromListNotification, object: self.price)
                    }) {
                        
                    }
                }
            }
                
            Section(header: Text( prices.count == 0 ? "" : "Prices previously entered")) {
                ForEach(prices, id:\.self) { price in
                    Button(action: {
                        self.price =  price
                        NotificationCenter.default.post(name: .priceModifiedFromListNotification, object: self.price)
                    }) {
                        Text(price)
                    }.padding(10)
                }
            }
            
        }.onAppear {
            self.price = "\(self.priceValue)"
            self.loadPrices()
        }.listStyle(GroupedListStyle())
        .navigationBarTitle("edit price")
    }
    
    func loadPrices() {
        var set = Set<String>()
        var list = try! Realm().objects(IncomeModel.self)
        if isIncome  {
            list = list.filter("value > %@", 0)
        } else {
            list = list.filter("value < %@", 0)
        }
        for model in list {
            set.insert("\(Int(abs(model.value)))")
        }
        prices = set.sorted(by: { (a, b) -> Bool in
            return a.floatValue > b.floatValue
        })
    }
    
    struct MakePriceView_Previews: PreviewProvider {
        static var previews: some View {
            MakePriceView(price: "100", isIncome: true)
        }
    }
}
