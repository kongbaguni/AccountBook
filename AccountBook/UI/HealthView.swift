//
//  HealthView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/24.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import HealthKit

struct HealthView: View {
    @State var healthManager:HealthManager? = nil
    @State var set:[HKQuantityTypeIdentifier] = []
    func getView(id:HKQuantityTypeIdentifier)->Text {
        if id == HKQuantityTypeIdentifier.stepCount {
            
            return Text("stepCount")
            
        }
        else if id == HKQuantityTypeIdentifier.flightsClimbed {
            return Text("flightsClimbed")
        } else {
            return Text("unknown")
        }
    }
    @State var isRequestedHealth = UserDefaults.standard.isRequestHealth
    
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
                    ForEach(set, id:\.self) { id in
                        self.getView(id: id)
                    }
                }
            }
        }
        .onAppear {
            if UserDefaults.standard.isRequestHealth {
                self.healthManager = HealthManager()
                self.healthManager?.sync(complete: { (data) in
                    print(data ?? "none")
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
}

struct HealthView_Previews: PreviewProvider {
    static var previews: some View {
        HealthView()
    }
}
