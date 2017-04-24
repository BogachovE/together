//
//  userMaper.swift
//  together
//
//  Created by ASda Bogasd on 29.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation


class UserMaper{
    
    
    static func userToDictionary(user: User) ->NSDictionary  {
        let dictionaryUser: NSDictionary
        dictionaryUser = ["id":user.id, "name":user.name, "email":user.email, "phone":user.phone, "friends":user.friends, "signedEvent":user.signedEvent, "title":user.title, "followersCount":user.followersCount, "description":user.description, "notificationId":user.notificationId, "contributedSum":user.contributedSum]
        return dictionaryUser
    }
    
    static func dictionaryToUser(userDictionary: NSDictionary, image: UIImage = #imageLiteral(resourceName: "face"))-> User{
        let user: User
        
        user = User(name: userDictionary.value(forKey: "name") as! String,
                    email: userDictionary.value(forKey: "email") as! String,
                    id: userDictionary.value(forKey: "id") as! UInt64,
                    phone: userDictionary.value(forKey: "phone") as! String,
                    photo: image,
                    friends: userDictionary.value(forKey: "friends") as! Array<UInt64>,
                    signedEvent: userDictionary.value(forKey: "signedEvent") as! Array<Int>,
                    title: userDictionary.value(forKey: "title") as! String,
                    followersCount: userDictionary.value(forKey: "followersCount") as! Int,
                    description: userDictionary.value(forKey: "description") as! String,
                    notificationId: userDictionary.value(forKey: "notificationId") as! String,
                    contributedSum: userDictionary.value(forKey: "contributedSum") as! Int)
        
        return user
    }
    
}

