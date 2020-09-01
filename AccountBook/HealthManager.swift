//
//  HealthManager.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/24.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import HealthKit

extension Notification.Name {
    /** 건강 정보 권한 갱신 옵서버*/
    static let healthAuthorazitionStatusDidUpdated = Notification.Name("healthAuthorazitionStatusDidUpdated_observer")
}

class HealthManager : NSObject, ObservableObject {
    struct ShareAuth {
        let sharingAuthorizeds:Set<HKQuantityTypeIdentifier>
        let sharingDenied:Set<HKQuantityTypeIdentifier>
    }
    let store = HKHealthStore()
    let readTypes:[HKQuantityTypeIdentifier] = [.stepCount, .distanceWalkingRunning]
    override init() {
        super.init()
        requestAuth()
    }
    
    func requestAuth() {
        var share = Set<HKSampleType>()
        
        var reads = Set<HKObjectType>()
        
        var sharingAuthorizeds = Set<HKQuantityTypeIdentifier>()
        var sharingDenied = Set<HKQuantityTypeIdentifier>()
        
        for type in  readTypes {
            if let t = HKObjectType.quantityType(forIdentifier: type) {
                reads.insert(t)
            }
            if let t = HKSampleType.quantityType(forIdentifier: type) {
                switch store.authorizationStatus(for: t) {
                case .notDetermined:
                    share.insert(t)
                case .sharingAuthorized:
                    sharingAuthorizeds.insert(type)
                case .sharingDenied:
                    sharingDenied.insert(type)
                default:
                    break
                }
            }
        }
        
        if share.count > 0 {
            store.requestAuthorization(toShare: share, read: reads) { (isSucess, error) in
                sharingAuthorizeds.removeAll()
                sharingDenied.removeAll()
                for type in  self.readTypes {
                    if let t = HKSampleType.quantityType(forIdentifier: type) {
                        switch self.store.authorizationStatus(for: t) {
                        case .notDetermined:
                            break
                        case .sharingAuthorized:
                            sharingAuthorizeds.insert(type)
                        case .sharingDenied:
                            sharingDenied.insert(type)
                        default:
                            break
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    UserDefaults.standard.isRequestHealthAuth = true
                    NotificationCenter.default.post(
                        name: .healthAuthorazitionStatusDidUpdated,
                        object: isSucess ? ShareAuth(sharingAuthorizeds: sharingAuthorizeds, sharingDenied: sharingDenied) : nil)
                }
            }
        }
        else {
            UserDefaults.standard.isRequestHealthAuth = true
            NotificationCenter.default.post(name: .healthAuthorazitionStatusDidUpdated, object: ShareAuth(sharingAuthorizeds: sharingAuthorizeds, sharingDenied: sharingDenied))
        }
        
    }
    
    func getCount(beforeDay:Int,type:HKQuantityType, complete:@escaping(_ count:Double)->Void) {
        let now = Date.getMidnightTime(beforeDay: beforeDay)
        let startOfDay = Calendar.current.startOfDay(for: now)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: type,
                                                quantitySamplePredicate: nil,
                                                options: [.cumulativeSum],
                                                anchorDate: startOfDay,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { _, result, error in
            var resultCount = 0.0
            guard let r = result else {
                return
            }
            r.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in
                
                if let sum = statistics.sumQuantity() {
                    // Get steps (they are of double type)                    
                    resultCount = sum.doubleValue(for: HKUnit.count())
                } // end if
                
                DispatchQueue.main.async {
                    HealthModel.update(dayBefore:beforeDay, type: type, value: resultCount) { (isSucess) in
                        complete(resultCount)
                    }
                }
            }
        }
        store.execute(query)
    }
    
    
}


//extension HKQuantityType {
//    static let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount)!
//    static let flightsClimbed = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
//}


extension HKSampleType {
    static let stepCount = HKSampleType.quantityType(forIdentifier: .stepCount)!
    static let flightsClimbed = HKSampleType.quantityType(forIdentifier: .flightsClimbed)!
    static let distanceWalkingRunning = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!
}
