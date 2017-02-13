//
//  Event.swift
//  together
//
//  Created by ASda Bogasd on 20.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation
import UIKit

class NotificationModel {
    var notifId:Int
    var text:String
    var status:String
    var userId:Int
    var type:String
    var usersNotifId: [String]
    var lang: String
    var fromId: Int
    var fromAvatar: UIImage
    
    
    
    
    init(notifId: Int = 0, text: String = "void text", status: String = "Unread", userId: Int = 0, type:String = "none", usersNotifId: [String] = [""], lang: String = "en", fromId: Int = 0, fromAvatar: UIImage = #imageLiteral(resourceName: "face")) {
        self.text = text
        self.notifId = notifId
        self.status = status
        self.userId = userId
        self.type = type
        self.usersNotifId = usersNotifId
        self.lang = lang
        self.fromId = fromId
        self.fromAvatar = fromAvatar
    }
}


