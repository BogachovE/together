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
        dictionaryUser = ["id":user.id, "name":user.name, "email":user.email, "phone":user.phone, "friends":user.friends, "signedEvent":user.signedEvent]
        return dictionaryUser
    }
}

