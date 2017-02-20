//
//  Event.swift
//  together
//
//  Created by ASda Bogasd on 20.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation
import UIKit

class Event {
    var id: Int
    var title: String
    var description: String
    var contrebuted: Int
    var photo: UIImage
    var category: String
    var ownerId: UInt64
    var likes: Array<Int>
    var location: String
    var startTime: Date
    var endTime: Date
    var signedUsers: Array<Int>
    
    
    
    init(title: String = "", description: String = "", id: Int = 0, photo: UIImage = #imageLiteral(resourceName: "EventPhoto"), contrebuted: Int = 0, category: String = "", ownerId: UInt64 = 0, likes: Array<Int> = [0], location: String = "", startTime: Date = Date(), endTime: Date = Date(), signedUsers: Array<Int> = [0]) {
        self.title = title
        self.id = id
        self.description = description
        self.photo = photo
        self.contrebuted = contrebuted
        self.category = category
        self.ownerId = ownerId
        self.likes = likes
        self.location = location
        self.startTime = startTime
        self.endTime = endTime
        self.signedUsers = signedUsers
            }
}


