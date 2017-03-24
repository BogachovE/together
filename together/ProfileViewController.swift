//
//  ProfileViewController.swift
//  together
//
//  Created by ASda Bogasd on 02.02.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit
import Firebase
import OneSignal

class ProfileViewController: UIViewController {
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var avatar: UIImageView!
    @IBOutlet weak var followingLabels: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subscribeBtnLabel: UILabel!
    @IBOutlet var subscribleButton: UIButton!
    @IBOutlet var contributed: UILabel!
    @IBOutlet var withdrawal: UIButton!
    @IBOutlet var contributedLabel: UILabel!
    
    var userId: UInt64 = 0
    var myId: UInt64 = 0
    var storageRef: FIRStorageReference!
    var ref: FIRDatabaseReference!
    var userRepositories: UserRepositories!
    var user: User!
    var notification: NotificationModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")

        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        
        //Load userDefaults
        let defaults = UserDefaults.standard
        myId = defaults.value(forKey: "userId") as! UInt64
        
        userRepositories = UserRepositories()
        userRepositories.loadUser(userId: UInt64(myId)/*userId*/, withh: { (user) in
            self.user = user
            self.setUserInfo(user: user)
            //maybe do func
            if (self.userId != self.myId && user.friends.contains(self.userId)){
                self.subscribeBtnLabel.text = "Unsubscrible"
            } else {
                self.subscribeBtnLabel.text = "Subscrible"
            }
        })
        
        if (userId == myId){
            subscribleButton.isHidden = true
            //showWithdrawal()
        }
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUserInfo(user:User){
        followersLabel.text = String(user.followersCount)
        loginLabel.text = user.name
        titleLabel.text = user.title
        avatar.image = user.photo
        followingLabels.text = String(user.friends.count - 1)
        descriptionLabel.text = user.description
        //contributed.text = "\(user.contributedSum)"   // MARK: спросить лешу
        
        
        
    }
    
    
    
    func makeToast(text: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center;
        self.view.addSubview(toastLabel)
        toastLabel.text = text
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        UIView.animate(withDuration: 4.0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            toastLabel.alpha = 0.0
        })
    }
    
    
    //Actions
    @IBAction func subscriblePressed(sender: AnyObject) {
        if (subscribeBtnLabel.text == "Unsubscrible"){
            let uscribeIndex = user.friends.index(of: userId)
            user.friends.remove(at: uscribeIndex!)
            let newFriendsList = user.friends
            ref.child("users/" + String(myId) + "/friends/").setValue(newFriendsList)
            
        } else {
            let notificationRepositories = NotificationRepositories()
            notificationRepositories.notificationCount(withh: {(count) in
                let notifText = self.user.name + " subscribe on you"
                self.notification = NotificationModel(notifId: Int(count)+1, text:notifText, userId:self.userId, type:"subscrible", usersNotifId:[self.user.notificationId] )
                self.user.friends.append(self.userId)
                self.ref.child("users/" + String(self.myId) + "/friends/").setValue(self.user.friends)
                OneSignal.postNotification(["contents": [self.notification.lang: self.notification.text], "include_player_ids": self.notification.usersNotifId])
                let notifDicionary = notificationMaper.notificationToDictionary(notification: self.notification)
                self.ref.child("notifications/"+String(count+1)+"/").setValue(notifDicionary)
            })
        }
    }
    
    
    
    
    

    
    
    
}
