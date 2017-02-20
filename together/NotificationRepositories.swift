//
//  NotificationRepositories.swift
//  together
//
//  Created by ASda Bogasd on 12.02.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation
import Firebase
import OneSignal

class NotificationRepositories{
    var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    var storage = FIRStorage.storage()
    var storageRef: FIRStorageReference!

    
    func notificationCount(withh: @escaping (UInt)->Void){
        ref.child("notifications").observeSingleEvent(of: .value, with: {(snapshot) in
            let count = snapshot.childrenCount
            withh(count)
        })
    }
    
    func likeNotification(event:Event, user:User, myId: Int){
        notificationCount(withh: {(count) in
            let userRepositories = UserRepositories()
            userRepositories.loadUser(userId: event.ownerId, withh: { (owner) in
                let notifcount = Int(count)
                let notifText = user.name + " like your event"
                let notification = NotificationModel(notifId: notifcount + 1, text: notifText, userId: owner.id, type: "like", usersNotifId: [owner.notificationId], fromId: myId)
                let notifDictionary = notificationMaper.notificationToDictionary(notification: notification)
                OneSignal.postNotification(["contents": [notification.lang: notification.text], "include_player_ids": notification.usersNotifId])
                self.ref.child("notifications/" + String(notifcount+1) + "/").setValue(notifDictionary)
            })
            
            
        })
    }
    
    func contributeNotification(event:Event, user:User, sum:Int){
        notificationCount(withh: {(count) in
//            let userRepositories = UserRepositories()
//            userRepositories.loadUser(userId: event.ownerId, withh: { (owner) in
//                let notifcount = Int(count)
//                let notifText = user.name + " contribute your event " + String(sum) + "$"
//                let notification = NotificationModel(notifId: notifcount + 1, text: notifText, userId: owner.id, type: "contribute", usersNotifId: [owner.notificationId])
//                let notifDictionary = notificationMaper.notificationToDictionary(notification: notification)
//                OneSignal.postNotification(["contents": [notification.lang: notification.text], "include_player_ids": notification.usersNotifId])
//                self.ref.child("notifications/" + String(notifcount+1) + "/").setValue(notifDictionary)
//            })
        })
    }
    
    func loadUserNotificatons(userId: Int, withh: @escaping (Array<NotificationModel>)->Void){
        var notifications: Array<NotificationModel>
        notifications = Array<NotificationModel>()

        let userRepositories = UserRepositories()
        let userNatifQuery = ref.child("notifications").queryOrdered(byChild: "userId").queryEqual(toValue: userId)
        userNatifQuery.observe(.value, with: {(snapshot) in
            if (snapshot.exists()){
                for childEvent in snapshot.children {
                    let storage = FIRStorage.storage()
                    self.storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
                    let childEvent = (childEvent as! FIRDataSnapshot).value as! NSDictionary
                    userRepositories.loadUserImage(id: childEvent.value(forKey: "fromId") as! UInt64, storage: self.storage, storageRef: self.storageRef, withh:{ (avatar) in
                        let notification = notificationMaper.dictionaryToNotification(notificationDictionary: childEvent, image: avatar)
                        notifications.append(notification)
                        withh(notifications)
                    })
                }
            } else {
                print("eror : There are no notidications")
                print("userId = ", userId)
            }
        })
    }
    
    
}
