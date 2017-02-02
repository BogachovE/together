//
//  ProfileViewController.swift
//  together
//
//  Created by ASda Bogasd on 02.02.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var avatar: UIImageView!
    @IBOutlet weak var followingLabels: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subscribeBtnLabel: UILabel!
    @IBOutlet var subscribleButton: UIButton!
    
    var userId: Int = 0
    var myId: Int = 0
    var storageRef: FIRStorageReference!
    var ref: FIRDatabaseReference!
    var userRepositories: UserRepositories!
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        
        //Load userDefaults
        let defaults = UserDefaults.standard
        myId = defaults.integer(forKey: "userId")
        
        userRepositories = UserRepositories()
        userRepositories.loadUser(userId: myId/*userId*/, withh: { (user) in
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
        
    }
    
    //Actions
    @IBAction func subscriblePressed(sender: AnyObject) {
        if (subscribeBtnLabel.text == "Unsubscrible"){
            let uscribeIndex = user.friends.index(of: userId)
            let str = String(describing: uscribeIndex) as String!
            print("users/" + String(myId/*userId*/) + "/friends/" + str!)
            user.friends.remove(at: uscribeIndex!)
            let newFriendsList = user.friends 
            ref.child("users/" + String(myId) + "/friends/").setValue(newFriendsList)
            
        } else {
            user.friends.append(userId)
            ref.child("users/" + String(myId) + "/friends/").setValue(user.friends)
        }
    }
    
    
}
