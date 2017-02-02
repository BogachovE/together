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
    
    @available(iOS 10.0, *)
    static func whatsappShare(event: Event){
        let originalString = "First Whatsapp Share"
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)
        
        let url  = URL(string: "whatsapp://send?text=Hello%2C%20World!")
        
        //Text which will be shared on WhatsApp is: "First Whatsapp Share"
        
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    static func twitterShare(event: Event, controller: UIViewController){
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            var twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Share on Twitter")
            controller.present(twitterSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            controller.present(alert, animated: true, completion: nil)
        }
    }
}
