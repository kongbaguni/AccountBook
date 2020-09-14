//
//  HealthModel.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/28.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import HealthKit

fileprivate func idValue(type:String,dayBefore:Int)->String {
    return "\(type)_\(Date.getMidnightTime(beforeDay: dayBefore).formatedString(format: "yyyyMMdd"))"
}

extension Notification.Name {
    static let healthDataDidUpdated = Notification.Name("healthDataDidUpdated_observer")
}

class HealthModel: Object {
    @objc dynamic var creator:String = ""
    @objc dynamic var id:String = ""
    @objc dynamic var type:String = ""
    @objc dynamic var startTimeInterval1970:Double = 0
    @objc dynamic var updateTimeInterval1970:Double = 0
    @objc dynamic var value:Double = 0
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension HealthModel {
    var startDate:Date {
        return Date(timeIntervalSince1970: startTimeInterval1970)
    }
    fileprivate static func create(beforeDay:Int,type:HKQuantityType, value:Double, complete:@escaping(_ isSucess:Bool)->Void) {
        let id = idValue(type:type.identifier, dayBefore: beforeDay)
        let data:[String:Any] = [
            "creator" : loginedEmail,
            "id": id,
            "value" : value,
            "type" : type.identifier,
            "startTimeInterval1970" : Date.getMidnightTime(beforeDay: beforeDay).timeIntervalSince1970,
            "updateTimeInterval1970" : Date().timeIntervalSince1970
        ]
        
        FS.collection(.FSCollectionName_health).document(loginedEmail).collection("data").document(id).setData(data) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(HealthModel.self, value: data, update: .all)
                try! realm.commitWrite()
            }
            NotificationCenter.default.post(name: .healthDataDidUpdated, object: id)
            complete(error == nil)
        }
    }
    
    fileprivate static func update(id:String, value:Double, complete:@escaping(_ isSucess:Bool)->Void) {
        let data:[String:Any] = [
            "id": id,
            "updateTimeInterval1970" : Date().timeIntervalSince1970,
            "value" : value
        ]
        FS.collection(.FSCollectionName_health).document(loginedEmail).collection("data").document(id).updateData(data) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(HealthModel.self, value: data, update: .modified)
                try! realm.commitWrite()
            }
            NotificationCenter.default.post(name: .healthDataDidUpdated, object: id)
            complete(error == nil)
        }
    }
    
    static func update(dayBefore:Int,type:HKQuantityType,value:Double, complete:@escaping(_ isSucess:Bool)->Void) {
        let id = idValue(type:type.identifier,dayBefore: dayBefore)
        if let data = try! Realm().object(ofType: HealthModel.self, forPrimaryKey: id) {
            update(id: data.id, value: value, complete: complete)
            return
        }
        create(beforeDay:dayBefore,type: type, value: value, complete: complete)
    }
    
    static func sync(complete:@escaping(_ isSucess:Bool)->Void) {
        var date:TimeInterval = 0
        if let last = try! Realm().objects(HealthModel.self).sorted(byKeyPath: "updateTimeInterval1970").last {
            date = last.startTimeInterval1970
        }
        
        FS.collection(.FSCollectionName_health)
            .document(loginedEmail).collection("data")
            .whereField("updateTimeInterval1970", isGreaterThanOrEqualTo: date)
            .getDocuments { (shot, error) in
            
            if let data = shot?.documents {
                let realm = try! Realm()
                realm.beginWrite()
                for d in data {
                    realm.create(HealthModel.self, value: d.data(), update: .all)
                }
                try! realm.commitWrite()
            }
            complete(error == nil)
        }
    }
}
