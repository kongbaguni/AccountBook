//
//  MakePriceView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/18.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift
import CoreLocation

extension Notification.Name {
    static let priceModifiedFromListNotification = Notification.Name(rawValue: "priceTagsNotification_observer")
}

struct MakePriceView: View {
    fileprivate var priceValue:String = ""
    fileprivate var isIncome:Bool = false
    
    @State var prices:[String] = []
    @State var price:String = ""
    var incomeId:String? = nil
    var incomeModel:IncomeModel? {
        if let id = incomeId {
            return try! Realm().object(ofType: IncomeModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    var location:CLLocation? {
        if let model = self.incomeModel {
            return CLLocation(latitude: model.latitude, longitude: model.longitude)
        }
        if let location = UserDefaults.standard.lastLocation {
            return location
        }
        return  nil
    }
    
    init(price:String, isIncome:Bool, incomeId:String?) {
        self.priceValue = price
        self.isIncome  = isIncome
        self.incomeId = incomeId
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
            
        }
        .navigationBarTitle("edit price")
        .onAppear {
            self.price = "\(self.priceValue)"
            self.loadPrices()
        }
        .listStyle(GroupedListStyle())
    }
    
    
    
    func loadPrices() {
        var set = Set<String>()
        var list = try! Realm().objects(IncomeModel.self)
        if let location = self.location?.coordinate {
            let minlat = location.latitude - 0.005
            let maxlat = location.latitude + 0.005
            let minlng = location.longitude - 0.005
            let maxlng = location.longitude + 0.005
            list = list.filter("latitude > %@ && latitude < %@ && longitude > %@ && longitude < %@"
                ,minlat, maxlat, minlng, maxlng)
        }
        
        
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
            MakePriceView(price: "100", isIncome: true, incomeId: nil)
        }
    }
}
