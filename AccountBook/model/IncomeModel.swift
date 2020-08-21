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
  
    var tagStringValue:String {
        
        var result = ""
        for tag in tagList {
            if !result.isEmpty {
                result.append(",")
            }
            result.append(tag)
        }
        return result
    }
    
    var isNew:Bool {
        let i = Date().timeIntervalSince1970 - updateTimeIntervalSince1970
        return i <= 1
    }
    
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
    
    
    var tagList:[String] {
        let set = Set<String>(tags.components(separatedBy: ","))
        return set.sorted()
    }
    
    public func addTag(tag:String, complete:@escaping(_ isSucess:Bool)->Void) {
        let tagList = tags.components(separatedBy: self.tags)
        var set = Set<String>(tagList)
        set.insert(tag)
        var tags:String = ""
        for t in set {
            if !tags.isEmpty {
                tags.append(",")
            }
            tags.append(t)
        }
        let data = ["tags" : tags, "id": self.id]
        TagModel.createTag(title: tag) { (isSucess) in
            FS.collection(.FSCollectionName_accountData).document(self.id).updateData(data) { (error) in
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(IncomeModel.self, value: data, update: .modified)
                try! realm.commitWrite()
                complete(error == nil)
            }
        }
    }
    
    static func create(id:String? = nil ,
                       value:Float, name:String, tags:String, coordinate2D:CLLocationCoordinate2D?, complete:@escaping(_ isSucess:Bool, _ id:String)->Void) {
        let isUpdate = id != nil
        let id = id ?? "\(UUID().uuidString)_\(Date().timeIntervalSince1970)_\(loginedEmail)"
        let newTags = tags.components(separatedBy: ",")
        var ttags:String = ","
        for t in newTags {
            let tt = t.trimmingValue
            if tt.isEmpty == false {
                ttags.append(tt)
                ttags.append(",")
            }
        }
        
        var data:[String:Any] = [
            "id" : id ,
            "value" : value,
            "name" : name,
            "tags" : ttags,
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
        
        let realm = try! Realm()
        realm.beginWrite()
        for tag in tags.components(separatedBy: ",") {
            let tagData:[String:Any] = [
                "title":tag.trimmingValue,
                "creatorEmail":loginedEmail,
                "regTimeIntervalSince1970":Date().timeIntervalSince1970,
                "latitude":0,
                "longitude":0
            ]
            realm.create(TagModel.self, value: tagData, update: .all)
        }
        try! realm.commitWrite()

        if isUpdate {
            FS.collection(.FSCollectionName_accountData).document(id).updateData(data) { (error) in
                if error == nil {
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.create(IncomeModel.self, value: data, update: .modified)
                    try! realm.commitWrite()
                }
                complete(error == nil, id)
            }
        }
        else {
            FS.collection(.FSCollectionName_accountData).document(id).setData(data) { (error) in
                if error == nil {
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.create(IncomeModel.self, value: data, update:.all)
                    try! realm.commitWrite()
                }
                complete(error == nil, id)
            }
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
    
    func delete(complete:@escaping(_ isSucess:Bool)->Void) {
        FS.collection(.FSCollectionName_accountData).document(self.id).delete { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                self.creatorEmail = "deleted"
                self.value = 0
                self.name = ""
                try! realm.commitWrite()
            }
            complete(error == nil)
        }
    }
}


extension IncomeModel {
    struct Data {
        let id:String
        var data:IncomeModel? {
            return try! Realm().object(ofType: IncomeModel.self, forPrimaryKey: id)
        }
    }
    
    var data:IncomeModel.Data {
        return IncomeModel.Data(id:id)
    }
}
