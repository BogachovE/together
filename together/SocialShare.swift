//
//  SocialShare.swift
//  together
//
//  Created by ASda Bogasd on 31.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation
import FacebookShare
import Social
import MessageUI

class SocialShare{
    
    
   static func shareToFacebook(event: Event, controller: UIViewController){
    if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
        let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        facebookSheet.setInitialText("Share on Facebook")
        
    } else {
        let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            }
    }
    
        
}
