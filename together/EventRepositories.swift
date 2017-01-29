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
            if (value?.value(forKey: "events") != nil){
                for item in (value?.value(forKey: "events") as? NSArray)! {
                    let child = item as! NSDictionary
                    var event: Event = Event()
                    
                    let storage = FIRStorage.storage()
                    self.storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
                    self.loadEventPhoto(eventId: child.value(forKey: "id") as! Int, storageRef: self.storageRef, withh: { (image) in
                        
                        event = EventMaper.dictionaryToEvent(eventDictionary: child, image: image)
                        
                        events.append(event)
                        withh(events)
                    })
                }
            }
        })
    
        
    }
    
    func loadCategoryEvents(category: String, withh: @escaping (Array<Event>)->Void){
        var events: Array<Event>
        events = Array<Event>()
        let categoryQuery = ref.child("events").queryOrdered(byChild: "category").queryEqual(toValue: category)
        categoryQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            print("value=", snapshot.value)
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                var event: Event = Event()
                event = Event(title: child.childSnapshot(forPath: "title").value as! String, description: child.childSnapshot(forPath: "description").value as! String, id: child.childSnapshot(forPath: "id").value as! Int, contrebuted: child.childSnapshot(forPath: "contrebuted").value as! Int, likes: child.childSnapshot(forPath: "likes").value as! Array<Int>)
                
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
                        event = Event(title: childEvent.childSnapshot(forPath: "title").value as! String, description: childEvent.childSnapshot(forPath: "description").value as! String, id: childEvent.childSnapshot(forPath: "id").value as! Int, contrebuted: childEvent.childSnapshot(forPath: "contrebuted").value as! Int, likes: childEvent.childSnapshot(forPath: "likes").value as! Array<Int>)
                        // print("eventId", event.id)
                        events.append(event)
                        print("event count ", events.count)
                    }
                    withh(events)
                    
                })
            }
        })
    }
    
    func loadSignedEvents(id: Int, withh: @escaping (Array<Event>)->Void)  {
        var events: Array<Event>
        events = Array<Event>()
        findSigned(id: id, withh: {(signeds)  in
            for signed in signeds {
                let signedsEventQuery = self.ref.child("events").queryOrdered(byChild: "id").queryEqual(toValue: signed)
                signedsEventQuery.observeSingleEvent(of: .value, with: { (snapshot) in
                    let child = snapshot
                    //print("friendId", friend)
                    // print("snapshot", snapshot)
                    var event: Event = Event()
                    for childEvent in child.children {
                        let childEvent = childEvent as! FIRDataSnapshot
                        event = Event(title: childEvent.childSnapshot(forPath: "title").value as! String, description: childEvent.childSnapshot(forPath: "description").value as! String, id: childEvent.childSnapshot(forPath: "id").value as! Int, contrebuted: childEvent.childSnapshot(forPath: "contrebuted").value as! Int, likes: childEvent.childSnapshot(forPath: "likes").value as! Array<Int>)
                        // print("eventId", event.id)
                        events.append(event)
                        print("event count ", events.count)
                    }
                    withh(events)
                    
                })
            }
        })
    }
    
    func loadMyEvents (id: Int, withh: @escaping (Array<Event>)->Void)  {
        var events: Array<Event>
        events = Array<Event>()
        let myEventQuery = self.ref.child("events").queryOrdered(byChild: "ownerId").queryEqual(toValue: id)
        myEventQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            let child = snapshot
            //print("friendId", friend)
            // print("snapshot", snapshot)
            var event: Event = Event()
            for childEvent in child.children {
                let childEvent = childEvent as! FIRDataSnapshot
                event = Event(title: childEvent.childSnapshot(forPath: "title").value as! String, description: childEvent.childSnapshot(forPath: "description").value as! String, id: childEvent.childSnapshot(forPath: "id").value as! Int, contrebuted: childEvent.childSnapshot(forPath: "contrebuted").value as! Int, likes: childEvent.childSnapshot(forPath: "likes").value as! Array<Int>)
                // print("eventId", event.id)
                events.append(event)
                print("event count ", events.count)
            }
            withh(events)
            
        })
        
    }
    
    func loadEventByHashtag(searchText: String, withh:@escaping (Array<Event>)->Void){
        
        
    }
    
    func findFriends(id: Int ,withh: @escaping (Array<Int>)->Void ){
        let friendsRef = ref.child("users/"+String(id))
        friendsRef.observe(.value, with: { snapshot in
            print("UserID", id)
            print("Snapshot", snapshot)
            let friends = snapshot.childSnapshot(forPath: "friends").value! as! Array<Int>
            withh(friends)
        })
    }
    
    func findSigned(id: Int ,withh: @escaping (Array<Int>)->Void ){
        let signedEventsRef = ref.child("users/"+String(id))
        signedEventsRef.observe(.value, with: { snapshot in
            print("UserID", id)
            print("Snapshot", snapshot)
            let signeds = snapshot.childSnapshot(forPath: "signedEvent").value! as! Array<Int>
            withh(signeds)
        })
    }
    
    func addNewEvent(event: Event, count: Int, storageRef: FIRStorageReference){
        let eventDictionary: NSDictionary
        eventDictionary = EventMaper.eventToDictionary(event: event)
        ref.child("events/"+String(count)+"/").setValue(eventDictionary)
        ref.child("eventscount").setValue(count+1)
        
        //Put image
        // Data in memory
        let data = UIImagePNGRepresentation(event.photo)
        
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("eventsPhoto/"+String(describing: event.id)+".jpg")
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.put(data!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL
            
            
        }
    }
    
    func loadEventCount(withh: @escaping (Int)->Void) {
        var count: Int = 0
        ref.child("eventscount").observeSingleEvent(of: .value, with: { (snapshot) in
            count = snapshot.value as! Int
            withh(count)
        })
    }
    
    func loadEventPhoto(eventId: Int,storageRef: FIRStorageReference, withh: @escaping (UIImage)->Void){
        var image :UIImage = UIImage()
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        let riversRef = storageRef.child("eventsPhoto/"+String(eventId)+".jpg")
        riversRef.data(withMaxSize: 120 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("EROR =",error)
            } else {
                // Data for "images/island.jpg" is returned
                image = UIImage(data: data!)!
                
            }
            withh(image)
        }
    }
    
    
    
    
}
