//
//  HealthView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/24.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import HealthKit
import RealmSwift

struct HealthView: View {
    var list:Results<HealthModel> {
        return try! Realm().objects(HealthModel.self).sorted(byKeyPath: "startDate")
    }
    
    var stepList:Results<HealthModel> {
        return list.filter("type = %@", HKQuantityType.stepCount.identifier)
    }
    
    @State var healthManager:HealthManager? = nil
    @State var set:[HKQuantityTypeIdentifier] = []
    
    @State var isRequestedHealth = UserDefaults.standard.isRequestHealth
    
    @State var stepIds:[String] = []
    var body: some View {
        List {
            if isRequestedHealth == false {
                Section(header: Text(" ")) {
                    Button(action: {
                        self.healthManager = HealthManager()
                    }) {
                        Text("use health")
                    }
                }
            } else if set.count == 0 {
                Section(header: Text(" ")) {
                    Text("no auth health")
                }
            } else {
                Section(header: Text(" ")) {
                    ForEach(stepIds, id:\.self) { id in
                        HealthListRowView(id:id)
                    }
                }
            }
        }
        .onAppear {
            self.loadData()
            if UserDefaults.standard.isRequestHealth {
                self.healthManager = HealthManager()
                self.healthManager?.getCount(type: .stepCount, complete: { (count) in
                    self.loadData()
                })
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("health")
        .onReceive(NotificationCenter.default.publisher(for: .healthAuthorazitionStatusDidUpdated)) { (out) in
            self.isRequestedHealth = UserDefaults.standard.isRequestHealth
            
            if let auth = out.object as? HealthManager.ShareAuth {
                self.set.removeAll()
                for id in auth.sharingAuthorizeds {
                    self.set.append(id)
                }
            }
        }

               
    }
    
    func loadData() {
        stepIds.removeAll()
        for step in stepList {
            stepIds.append(step.id)
        }
    }
}

struct HealthView_Previews: PreviewProvider {
    static var previews: some View {
        HealthView()
    }
}
