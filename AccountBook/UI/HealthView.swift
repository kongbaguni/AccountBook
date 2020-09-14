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
import SwiftUICharts
import WaterfallGrid

struct HealthView: View {
    var list:Results<HealthModel> {
        return try! Realm().objects(HealthModel.self)
            .filter("startTimeInterval1970 > %@",Date.getMidnightTime(before: 7, type: Consts.dayRangeSelection).timeIntervalSince1970)
            .sorted(byKeyPath: "startTimeInterval1970")
    }
    
    var isChackYesterDay : Bool {
        return false
//        return try! Realm().objects(HealthModel.self).filter("updateTimeInterval1970 > %@", Date.midnightTodayTime.timeIntervalSince1970).count > 1
    }
    
    var isNeedTodayCheck : Bool {
        return try! Realm().objects(HealthModel.self).filter("updateTimeInterval1970 > %@", Date().timeIntervalSince1970 - 30).count == 0
    }
    
    var stepList:Results<HealthModel> {
        return list.filter("type = %@", HKQuantityType.stepCount.identifier)
    }
    
    @State private var animationAmount: Double = 3.14

    @State var healthManager:HealthManager? = nil
    @State var set:[HKQuantityTypeIdentifier] = []
    
    @State var isRequestedHealthAuth = UserDefaults.standard.isRequestHealthAuth
    
    @State var stepIds:[String] = []
    @State var dayBefore:Int = 0
    @State var isRequestHealthInfo:Bool = false
    
    var dayString:String {
        return Date.getMidnightTime(beforeDay: dayBefore).simpleFormatStringValue
    }
    
    @State var steps:[Double] = []
    
    @State var chartData:ChartData = ChartData(points: [0,0,0,0,0,0])
    
    func getHealthData() {
        if self.isChackYesterDay == false {
            self.isRequestHealthInfo = true
            self.healthManager?.getCount(beforeDay: 1, type: .stepCount, complete: { (count) in
                self.isRequestHealthInfo = false
                self.loadData()
            })
        }
        if self.isNeedTodayCheck {
            self.isRequestHealthInfo = true
            self.healthManager?.getCount(beforeDay: 0, type: .stepCount, complete: { (count) in
                self.isRequestHealthInfo = false
                self.loadData()
            })
        }
        self.healthManager?.getCount(beforeDay: 0, type: .heartRate, complete: { (count) in
            
        })
    }
    
    var body: some View {
        ZStack  {
            VStack {
                if isRequestedHealthAuth == false {
                    Section(header: Text(" ")) {
                        Button(action: {
                            self.healthManager = HealthManager()
                        }) {
                            Text("use health")
                        }
                    }
                } else {
                    WaterfallGrid((0..<3), id: \.self) { index in
                        VStack {
                            HStack {
                                Text("Today")
                                    .font(.title)
                                Text("\(Int(self.steps.last ?? 0))")
                                    .font(.caption)
                                    .foregroundColor(.orangeColor)
                                Text("steps")
                                    .font(.caption)
                            }
                            BarChartView(data: self.chartData, title: "step", legend: "day")
                                .padding(10)
                        }.padding()
                        
                    }.gridStyle(columns: 2)
                }

            }
            if self.isRequestHealthInfo {
                Text("Request Health info....")
                    .padding(10)
                    .background(Capsule().foregroundColor(.orangeColor))
                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    .rotation3DEffect(Angle(degrees: animationAmount), axis: (x: 10, y:5, z: 10))
                    .animation(
                        Animation.easeInOut(duration: 0.25)
                            .repeatForever(autoreverses: true))
                    .onAppear {
                         self.animationAmount = 5 * 3.14
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
                self.getHealthData()
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
                self.getHealthData()
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
        steps.removeAll()
        for step in stepList {
            stepIds.append(step.id)
            steps.append(step.value)
        }
        chartData = ChartData(points: steps)
    }
}

struct HealthView_Previews: PreviewProvider {
    static var previews: some View {
        HealthView()
    }
}
