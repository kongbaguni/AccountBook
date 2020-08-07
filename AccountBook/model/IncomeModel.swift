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
}
