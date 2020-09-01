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
        return try! Realm().objects(HealthModel.self).sorted(byKeyPath: "startTimeInterval1970")
    }
    
    var stepList:Results<HealthModel> {
        return list.filter("type = %@", HKQuantityType.stepCount.identifier)
    }
    
    @State var healthManager:HealthManager? = nil
    @State var set:[HKQuantityTypeIdentifier] = []
    
    @State var isRequestedHealthAuth = UserDefaults.standard.isRequestHealthAuth
    
    @State var stepIds:[String] = []
    @State var dayBefore:Int = 0
    @State var isRequestHealthInfo:Bool = false
    var dayString:String {
        return Date.getMidnightTime(beforeDay: dayBefore).simpleFormatStringValue
    }
    
    
    var body: some View {
        VStack {
            if self.isRequestHealthInfo {
                Text("Request Health info....")
            }
            
            HStack {
                Button(action: {
                    self.dayBefore += 1
                    NotificationCenter.default.post(name:.todaySelectorDidUpdated, object:self.dayBefore)
                }) {
                    Text("<").padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                }
                Button(action: {
                    self.dayBefore = 0
                    NotificationCenter.default.post(name:.todaySelectorDidUpdated, object:self.dayBefore)
                }) {
                    Text(dayString).font(.headline)
                }.disabled(dayBefore == 0)
                Button(action: {
                    self.dayBefore -= 1
                    NotificationCenter.default.post(name:.todaySelectorDidUpdated, object:self.dayBefore)
                }) {
                    Text(">").padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                }.disabled(dayBefore == 0)
            }
            List {
                
                if isRequestedHealthAuth == false {
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
        }
        .onAppear {
            self.loadData()
            if UserDefaults.standard.isRequestHealthAuth {
                self.healthManager = HealthManager()
                HealthModel.sync { (isSucess) in
                    if isSucess {
                        self.loadData()
                    }
                }
                self.isRequestHealthInfo = true
                self.healthManager?.getCount(beforeDay: self.dayBefore, type: .stepCount, complete: { (count) in
                    self.isRequestHealthInfo = false
                    self.loadData()
                })
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("health")
        .onReceive(NotificationCenter.default.publisher(for: .healthAuthorazitionStatusDidUpdated)) { (out) in
            self.isRequestedHealthAuth = UserDefaults.standard.isRequestHealthAuth
            
            if let auth = out.object as? HealthManager.ShareAuth {
                self.set.removeAll()
                for id in auth.sharingAuthorizeds {
                    self.set.append(id)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .todaySelectorDidUpdated)) { (output) in
            self.isRequestHealthInfo = true
            self.healthManager?.getCount(beforeDay: self.dayBefore, type: .stepCount, complete: { (count) in
                self.isRequestHealthInfo = false
                self.loadData()
            })
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
