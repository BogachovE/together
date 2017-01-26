//
//  EventRepositories.swift
//  together
//
//  Created by ASda Bogasd on 20.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation
import Firebase

class  EventRepositories {
    var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    var storageRef: FIRStorageReference!
    
    func loadAllEvents(withh: @escaping (Array<Event>)->Void) {
        var events: Array<Event>
        events = Array<Event>()
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            for item in value?.value(forKey: "events") as! NSArray {
                let child = item as! NSDictionary
                var event: Event = Event()
                event = Event(title: child.value(forKey: "title")! as! String, description: child.value(forKey: "description") as! String, id: child.value(forKey: "id") as! Int, contrebuted: child.value(forKey: "contrebuted") as! Int)
                
                events.append(event)
            }
            withh(events)
        })
        
    }
    
    func loadCategoryEvents(category: String, withh: @escaping (Array<Event>)->Void){
        var events: Array<Event>
        events = Array<Event>()
        let categoryQuery = ref.child("events").queryOrdered(byChild: "category").queryEqual(toValue: category)
        categoryQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                var event: Event = Event()
                event = Event(title: child.childSnapshot(forPath: "title").value as! String, description: child.childSnapshot(forPath: "description").value as! String, id: child.childSnapshot(forPath: "id").value as! Int, contrebuted: child.childSnapshot(forPath: "contrebuted").value as! Int)
                
                events.append(event)
            }
            withh(events)
        })
    }
    
    func loadFriendsEvents(id: Int, withh: @escaping (Array<Event>)->Void)  {
        var events: Array<Event>
        events = Array<Event>()
        findFriends(id: id, withh: {(friends)  in
            for friend in friends {
                let friendsEventQuery = self.ref.child("events").queryOrdered(byChild: "ownerId").queryEqual(toValue: friend)
                friendsEventQuery.observeSingleEvent(of: .value, with: { (snapshot) in
                    let child = snapshot
                    //print("friendId", friend)
                   // print("snapshot", snapshot)
                    var event: Event = Event()
                    for childEvent in child.children {
                        let childEvent = childEvent as! FIRDataSnapshot
                        event = Event(title: childEvent.childSnapshot(forPath: "title").value as! String, description: childEvent.childSnapshot(forPath: "description").value as! String, id: childEvent.childSnapshot(forPath: "id").value as! Int, contrebuted: childEvent.childSnapshot(forPath: "contrebuted").value as! Int)
                       // print("eventId", event.id)
                        events.append(event)
                        print("event count ", events.count)
                    }
                    withh(events)

                })
            }
                  })
        
        
        
        
    }
    
    func findFriends(id: Int ,withh: @escaping (Array<Int>)->Void ){
        let friendsRef = ref.child("users/"+String(id))
        friendsRef.observe(.value, with: { snapshot in
            let friends = snapshot.childSnapshot(forPath: "friends").value! as! Array<Int>
            withh(friends)
        })
    }
    
}
