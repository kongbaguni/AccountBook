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
    let readTypes:[HKQuantityTypeIdentifier] = [.flightsClimbed, .stepCount]
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
                    UserDefaults.standard.isRequestHealth = true
                    NotificationCenter.default.post(
                        name: .healthAuthorazitionStatusDidUpdated,
                        object: isSucess ? ShareAuth(sharingAuthorizeds: sharingAuthorizeds, sharingDenied: sharingDenied) : nil)
                }
            }
        }
        else {
            UserDefaults.standard.isRequestHealth = true
            NotificationCenter.default.post(name: .healthAuthorazitionStatusDidUpdated, object: ShareAuth(sharingAuthorizeds: sharingAuthorizeds, sharingDenied: sharingDenied))
        }
        
    }
    
    func sync(complete:@escaping(_ data:[HKQuantityType : HKUnit]?)->Void) {
        var set = Set<HKQuantityType>()
        for id in self.readTypes {
            if let type = HKQuantityType.quantityType(forIdentifier: id) {
                set.insert(type)
            }
        }
        store.preferredUnits(for: set) { (data, error) in
            if error == nil {
                for d in data {
                    switch d.key {
                    case .stepCount:
                        print("stepCount: \(d.value.accessibilityElementCount())")
                        let predicate = HKQuery.predicateForSamples(withStart: Date.getMidnightTime(beforeDay: 10), end: Date.getMidnightTime(beforeDay: 0), options: .strictEndDate)
                       
                        _ = HKSampleQuery(
                            sampleType: .stepCount,
                            predicate: predicate,
                            limit: HKObjectQueryNoLimit,
                            sortDescriptors: nil) { (query, sample, error) in
                                if let data = sample {
                                    for d in data {
                                        print("======")
                                        print(d.startDate.simpleFormatStringValue)
                                        print(d.endDate.simpleFormatStringValue)
                                        print(d)
                                    }
                                }
                            
                        }
                        
                                               
                        break

                    case .flightsClimbed:
                        print("flightsClimbed: \(d.value.accessibilityElementCount())")

                        break
                    default:
                        break
                    }
                }
                complete(data)
            } else {
                complete(nil)
            }
        }
    }
}


//extension HKQuantityType {
//    static let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount)!
//    static let flightsClimbed = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
//}


extension HKSampleType {
    static let stepCount = HKSampleType.quantityType(forIdentifier: .stepCount)!
    static let flightsClimbed = HKSampleType.quantityType(forIdentifier: .flightsClimbed)!
}
