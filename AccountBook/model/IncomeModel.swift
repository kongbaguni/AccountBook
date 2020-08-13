//
//  IncomeModel.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/07.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation
class IncomeModel: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var value:Float = 0
    @objc dynamic var name:String = ""
    @objc dynamic var tags:String = ""
    @objc dynamic var latitude:Double = 0
    @objc dynamic var longitude:Double = 0
    @objc dynamic var creatorEmail:String = ""
    @objc dynamic var regTimeIntervalSince1970:Double = 0
    @objc dynamic var updateTimeIntervalSince1970:Double = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["creatorEmail","name","tags"]
    }
}

extension IncomeModel {
    
    var regTime:Date {
        return Date(timeIntervalSince1970: regTimeIntervalSince1970)
    }
    
    var updateTime:Date {
        return Date(timeIntervalSince1970: updateTimeIntervalSince1970)
    }
    
    var coordinate2D:CLLocationCoordinate2D? {
        if latitude == 0 && longitude == 0 {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var creator:UserInfoModel? {
        return try! Realm().object(ofType: UserInfoModel.self, forPrimaryKey: creatorEmail)
    }
    
    var tagList:[TagModel] {
        var list:[TagModel] = []
        for tag in tags.components(separatedBy: ",") {
            if let model = try! Realm().object(ofType: TagModel.self, forPrimaryKey: tag) {
                list.append(model)
            }
        }
        return list
    }
    
    
    static func create(id:String? = nil ,
        value:Float, name:String, tags:String, coordinate2D:CLLocationCoordinate2D?, complete:@escaping(_ isSucess:Bool)->Void) {
        let isUpdate = id != nil
        let id = id ?? "\(UUID().uuidString)_\(Date().timeIntervalSince1970)_\(loginedEmail)"
        var data:[String:Any] = [
            "id" : id ,
            "value" : value,
            "name" : name,
            "tags" : tags,
            "latitude" : coordinate2D?.latitude ?? 0,
            "longitude" : coordinate2D?.longitude ?? 0,
            "creatorEmail" : loginedEmail,
        ]
        let now = Date().timeIntervalSince1970
        if isUpdate {
            data["updateTimeIntervalSince1970"] = now
        } else {
            data["regTimeIntervalSince1970"] = now
            data["updateTimeIntervalSince1970"] = now
        }
        
        FS.collection(.FSCollectionName_accountData).document(id).setData(data) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(IncomeModel.self, value: data, update: isUpdate ? .modified : .all)
                try! realm.commitWrite()
            }
            complete(error == nil)
        }
    }
    
    static func sync(complete:@escaping(_ isSucess:Bool)->Void) {
        var syncDt:Double = 0
        
        if let last = try! Realm().objects(IncomeModel.self).sorted(byKeyPath: "updateTimeIntervalSince1970").last {
            syncDt = last.regTimeIntervalSince1970
        }
        FS.collection(.FSCollectionName_accountData)
            .whereField("updateTimeIntervalSince1970", isGreaterThan: syncDt)
            .getDocuments { (snapShot, error) in
                print(snapShot?.documents ?? "")
                let realm = try! Realm()
                realm.beginWrite()
                for doc in snapShot?.documents ?? [] {
                    realm.create(IncomeModel.self, value: doc.data(), update: .all)
                }
                try! realm.commitWrite()
                complete(error == nil)
        }
    }
}
