//
//  notificationMaper.swift
//  together
//
//  Created by ASda Bogasd on 12.02.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation


class notificationMaper{
    
    
    static func notificationToDictionary(notification: NotificationModel) ->NSDictionary  {
        let dictionaryNotification: NSDictionary
        dictionaryNotification = ["notifId":notification.notifId, "text":notification.text, "status":notification.status, "userId":notification.userId, "type":notification.type, "usersNotifId":notification.usersNotifId, "lang":notification.lang, "fromId":notification.fromId]
        return dictionaryNotification
    }

    static func dictionaryToNotification(notificationDictionary: NSDictionary, image: UIImage = #imageLiteral(resourceName: "face"))-> NotificationModel{
        let notification: NotificationModel
        
        notification = NotificationModel(notifId: notificationDictionary.value(forKey: "notifId") as! Int, text: notificationDictionary.value(forKey: "text") as! String, status: notificationDictionary.value(forKey: "status") as! String, userId: notificationDictionary.value(forKey: "userId") as! UInt64, type: notificationDictionary.value(forKey: "type") as! String, usersNotifId: notificationDictionary.value(forKey: "usersNotifId") as! [String], lang: notificationDictionary.value(forKey: "lang") as! String, fromId: notificationDictionary.value(forKey: "fromId") as! UInt64, fromAvatar: image)
        
        return notification
    }
    
}

