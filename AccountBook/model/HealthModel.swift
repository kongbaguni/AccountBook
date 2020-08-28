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

extension Notification.Name {
    static let healthDataDidUpdated = Notification.Name("healthDataDidUpdated_observer")
}

class HealthModel: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var type:String = ""
    @objc dynamic var startDate:Date = Date(timeIntervalSinceNow: 0)
    @objc dynamic var value:Double = 0
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension HealthModel {
    fileprivate static func create(type:HKQuantityType, value:Double, complete:@escaping(_ isSucess:Bool)->Void) {
        let id = "\(loginedEmail)_\(Date().timeIntervalSince1970)_\(UUID().uuidString)"
        let data:[String:Any] = [
            "id": id,
            "startDate" : Date.midnightTodayTime,
            "value" : value,
            "type" : type.identifier
        ]
        
        FS.collection(.FSCollectionName_health).document(id).setData(data) { (error) in
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
            "value" : value
        ]
        FS.collection(.FSCollectionName_health).document(id).updateData(data) { (error) in
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
    
    static func update(type:HKQuantityType,value:Double, complete:@escaping(_ isSucess:Bool)->Void) {
        if let data = try! Realm().objects(HealthModel.self).filter("type = %@",type.identifier).sorted(byKeyPath: "startDate").last {
            if data.startDate == Date.midnightTodayTime {
                update(id: data.id, value: value, complete: complete)
                return
            }
        }
        create(type: type, value: value, complete: complete)
    }
}
