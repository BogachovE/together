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
    var ownerId: Int
    var likes: Array<Int>
    var location: String
    var startTime: Date
    var endTime: Date
    
    
    
    init(title: String = "", description: String = "", id: Int = 00, photo: UIImage = #imageLiteral(resourceName: "EventPhoto"), contrebuted: Int = 0, category: String = "", ownerId: Int = 0, likes: Array<Int> = [00], location: String = "", startTime: Date = Date(), endTime: Date = Date()) {
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
            }
}


