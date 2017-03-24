//
//  User.swift
//  together
//
//  Created by ASda Bogasd on 16.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation
import UIKit

class User : Mappable {
   
    var id: UInt64
    var name: String
    var email: String
    var phone: String
    var photo: UIImage
    var friends: Array<UInt64>
    var signedEvent: Array<Int>
    var title: String
    var followersCount: Int
    var description: String
    var notificationId: String
    var contributedSum: Int
    
    init(name: String = "", email: String = "", id: UInt64 = 0, phone: String = "", photo: UIImage = #imageLiteral(resourceName: "photo_edit"), friends: Array<UInt64> = [0], signedEvent: Array<Int> = [0], title: String = "", followersCount:Int = 0, description:String = "", notificationId: String = "", contributedSum: Int = 0) {
        self.name = name
        self.id = id
        self.email = email
        self.phone = phone
        self.photo = photo
        self.friends = friends
        self.signedEvent = signedEvent
        self.title = title
        self.followersCount = followersCount
        self.description = description
        self.notificationId = notificationId
        self.contributedSum = contributedSum
    }
    
    internal static func modelToDictionary(model: Any?) -> NSDictionary {
        let model = model as! User
        let dictionaryUser: NSDictionary
        dictionaryUser = ["id":model.id,
                          "name":model.name,
                          "email":model.email,
                          "phone":model.phone,
                          "friends":model.friends,
                          "signedEvent":model.signedEvent,
                          "title":model.title,
                          "followersCount":model.followersCount,
                          "description":model.description,
                          "notificationId":model.notificationId,
                          "contributedSum":model.contributedSum
        ]
        return dictionaryUser
    }
    
    internal static func dictionaryToModel(dictionary: NSDictionary) -> Any? {
        let user: User
        user = User(name: dictionary.value(forKey: "name") as! String,
                    email: dictionary.value(forKey: "email") as! String,
                    id: UInt64(dictionary.value(forKey: "id") as! Int),
                    phone: dictionary.value(forKey: "phone") as! String,
                    photo: dictionary.value(forKey: "photo") as! UIImage,
                    friends: dictionary.value(forKey: "friends") as! Array<UInt64>,
                    signedEvent: dictionary.value(forKey: "signedEvent") as! Array<Int>,
                    title: dictionary.value(forKey: "title") as! String,
                    followersCount: dictionary.value(forKey: "followersCount") as! Int,
                    description: dictionary.value(forKey: "description") as! String,
                    notificationId: dictionary.value(forKey: "notificationId") as! String,
                    contributedSum: dictionary.value(forKey: "contributedSum") as! Int)
        
        return user
    }
    
    
}
