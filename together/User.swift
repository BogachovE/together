//
//  User.swift
//  together
//
//  Created by ASda Bogasd on 16.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation
import UIKit

class User {
    var id: Int
    var name: String
    var email: String
    var phone: String
    var photo: UIImage
    var friends: Array<Int>
    var signedEvent: Array<Int>
    
    init(name: String = "", email: String = "", id: Int = 0, phone: String = "", photo: UIImage = #imageLiteral(resourceName: "photo_edit"), friends: Array<Int> = [0], signedEvent: Array<Int> = [0]) {
        self.name = name
        self.id = id
        self.email = email
        self.phone = phone
        self.photo = photo
        self.friends = friends
        self.signedEvent = signedEvent
    }
}
