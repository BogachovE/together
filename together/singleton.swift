//
//  singleton.swift
//  together
//
//  Created by ASda Bogasd on 16.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation
import Firebase
import FBSDKCoreKit
import GoogleSignIn

class OnlyOneST{
    static var xredo = OnlyOneST()
   
    func setC(cred: FIRAuthCredential)  {
        OnlyOneST.xredo = cred as? Any as! OnlyOneST    }
}



