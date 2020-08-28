//
//  HealthListRowView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/28.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift

struct HealthListRowView: View {
    private let id:String
    init(id:String) {
        self.id = id
    }
    @State var type:String = ""
    @State var date:String = ""
    @State var value:String = ""
    
    var model:HealthModel? {
        return try! Realm().object(ofType: HealthModel.self, forPrimaryKey: id)
    }
    
    func loadData() {
        if let m = model {
            type = m.type
            date = m.startDate.simpleFormatStringValue
            value = "\(m.value)"
        }
    }
    
    
    var body: some View {
        VStack {
            Text(type)
            Text(date)
            Text(value)
        }.onReceive(NotificationCenter.default.publisher(for: .healthDataDidUpdated)) { (output) in
            if output.object as? String == self.id {
                self.loadData()
            }
        }.onAppear {
            self.loadData()
        }
    }
}

struct HealthListRowView_Previews: PreviewProvider {
    static var previews: some View {
        HealthListRowView(id:"test")
    }
}
