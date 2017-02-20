//
//  NewsViewController.swift
//  together
//
//  Created by ASda Bogasd on 23.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit
import Firebase

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    @IBOutlet var newsTableView: UITableView!
    @IBOutlet weak var loginView: UILabel!
    @IBOutlet weak var avatarImage: UIButton!
    
    var id: Int!
    var userRepositories: UserRepositories!
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var notificationRepositories: NotificationRepositories!
    var notifications: Array<NotificationModel>!
    var notifIcons: [UIImage]!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        notifications = Array<NotificationModel>()
        
        notifIcons = [#imageLiteral(resourceName: "likeActiveIcon"),#imageLiteral(resourceName: "user_icon"),#imageLiteral(resourceName: "dolar")]
        
        //Load userDefaults
        let defaults = UserDefaults.standard
        id = defaults.integer(forKey: "userId")
        
        let notificationRepositories = NotificationRepositories()
        notificationRepositories.loadUserNotificatons(userId: id, withh: { (notifications) in
            self.notifications = notifications
            self.newsTableView.reloadData()
        })

        self.newsTableView.delegate = self
        self.newsTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        //Load avatar and Login
        userRepositories = UserRepositories()
       
        userRepositories.loadUserImage(id: UInt64(id), storage: storage, storageRef: storageRef, withh: {(image) in
            self.avatarImage.setImage(image, for: .normal)
        })
        userRepositories.loadLogin(id:id, withh: {(name) in
            self.loginView.text = name
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        
        if(segue.identifier == "fromNewsToProfile"){
            let svc = segue.destination as! ProfileViewController
            
            svc.userId = self.id
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
        cell.textLabrl.text = notifications[indexPath.row].text
        cell.topicLabel.text = notifications[indexPath.row].type
        cell.avatarImage.image = notifications[indexPath.row].fromAvatar
        switch (notifications[indexPath.row].type){
        case "like" :
            cell.typeIcon.image = notifIcons[0]
        case "contributed" :
            cell.typeIcon.image = notifIcons[2]
        case "subscrible" :
            cell.typeIcon.image = notifIcons[1]
        default:
            print("error")
        }
    
    
        return cell
    }
   

}
