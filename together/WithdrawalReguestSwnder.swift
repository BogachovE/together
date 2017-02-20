//
//  WithdrawalReguestSwnder.swift
//  together
//
//  Created by ASda Bogasd on 20.02.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation
import Firebase

class WithdrawalReguestSender{
    static func send(sum:Int, adress:String, user:User){
        let ref = FIRDatabase.database().reference()
        ref.child("WithdrawalReguest/").observeSingleEvent(of: .value, with: { (snaphot) in
            let count = snaphot.childrenCount
            let reguest = ["PayPalAdress": adress,
                           "fromUser":user.name,
                           "userId":user.id,
                           "sum":sum
                ] as [String : Any]
            ref.child("WithdrawalReguest/\(count)").setValue(reguest)
        })
        
    }
}
