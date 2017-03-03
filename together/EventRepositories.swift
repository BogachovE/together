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
                    if (item as? NSDictionary != nil){
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
            }
        })
    
        
    }
    
    func loadCategoryEvents(category: String, withh: @escaping (Array<Event>)->Void){
        var events: Array<Event>
        events = Array<Event>()
        let categoryQuery = ref.child("events").queryOrdered(byChild: "category").queryEqual(toValue: category)
        categoryQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            for item in snapshot.children {
                let child = (item as! FIRDataSnapshot).value as! NSDictionary
                var event: Event = Event()
                let storage = FIRStorage.storage()
                self.storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
                self.loadEventPhoto(eventId: child.value(forKey: "id") as! Int, storageRef: self.storageRef, withh: { (image) in
                    
                    event = EventMaper.dictionaryToEvent(eventDictionary: child, image: image)
                    
                    events.append(event)
                    withh(events)
                })
            }
        })
            withh(events)
    }
    
    func loadFriendsEvents(id: Int, withh: @escaping (Array<Event>)->Void)  {
        var events: Array<Event>
        events = Array<Event>()
        findFriends(id: id, withh: {(friends)  in
            for friend in friends {
                let friendsEventQuery = self.ref.child("events").queryOrdered(byChild: "ownerId").queryEqual(toValue: friend)
                friendsEventQuery.observeSingleEvent(of: .value, with: { (snapshot) in
                    let child = snapshot
                    var event: Event = Event()
                    for childEvent in child.children {
                        let childEvent = ((childEvent as! FIRDataSnapshot).value) as! NSDictionary
                        let storage = FIRStorage.storage()
                        self.storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
                        self.loadEventPhoto(eventId: childEvent.value(forKey: "id") as! Int, storageRef: self.storageRef, withh: { (image) in
                            event = EventMaper.dictionaryToEvent(eventDictionary: childEvent, image: image)
                            events.append(event)
                            withh(events)
                        })
                    }
                })
                withh(events)
            }
        })
    }
    
    func loadSignedEvents(id: Int, withh: @escaping (Array<Event>)->Void)  {
        var events: Array<Event>
        events = Array<Event>()
        findSigned(id: id, withh: {(signeds)  in
            for signed in signeds {
                if (signed != 0) {
                    let signedsEventQuery = self.ref.child("events").queryOrdered(byChild: "id").queryEqual(toValue: signed)
                    signedsEventQuery.observeSingleEvent(of: .value, with: { (snapshot) in
                        let child = snapshot
                        var event: Event = Event()
                        for childEvent in child.children {
                            let childEvent = (childEvent as! FIRDataSnapshot).value  as! NSDictionary
                            let storage = FIRStorage.storage()
                            self.storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
                            self.loadEventPhoto(eventId: childEvent.value(forKey: "id") as! Int, storageRef: self.storageRef, withh: { (image) in
                                event = EventMaper.dictionaryToEvent(eventDictionary: childEvent, image: image)
                                events.append(event)
                                withh(events)
                            })
                        }
                    })
                }
                withh(events)
            }
        })
    }
    
    func loadMyEvents (id: Int, withh: @escaping (Array<Event>)->Void)  {
        var events: Array<Event>
        events = Array<Event>()
        let myEventQuery = self.ref.child("events").queryOrdered(byChild: "ownerId").queryEqual(toValue: id)
        myEventQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            let child = snapshot
            var event: Event = Event()
            for childEvent in child.children {
                let childEvent = (childEvent as! FIRDataSnapshot).value as! NSDictionary
                let storage = FIRStorage.storage()
                self.storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
                self.loadEventPhoto(eventId: childEvent.value(forKey: "id") as! Int, storageRef: self.storageRef, withh: { (image) in
                    event = EventMaper.dictionaryToEvent(eventDictionary: childEvent, image: image)
                    events.append(event)
                    withh(events)
                })
            }
        })
        
    }
    
    func loadEventByHashtag(searchText: String, withh:@escaping (Array<Event>)->Void){
        
        
    }
    
    func findFriends(id: Int ,withh: @escaping (Array<Int>)->Void ){
        let friendsRef = ref.child("users/"+String(id))
        friendsRef.observe(.value, with: { snapshot in
        let friends = snapshot.childSnapshot(forPath: "friends").value! as! Array<Int>
            withh(friends)
        })
    }
    
    func findSigned(id: Int ,withh: @escaping (Array<Int>)->Void ){
        let signedEventsRef = ref.child("users/"+String(id))
        signedEventsRef.observe(.value, with: { snapshot in
            let snapshot = snapshot.value as! NSDictionary
            let signeds = snapshot.value(forKey: "signedEvent") as! Array<Int>
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
    
    func loadEvent(eventId: Int, withh: @escaping (Event)->Void){
        let eventRef = ref.child("events/"+String(eventId)).observe(.value, with: { (snapshot) in
            let eventDictionary = snapshot.value as? NSDictionary
            let storage = FIRStorage.storage()
            self.storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
            self.loadEventPhoto(eventId: eventId, storageRef: self.storageRef, withh:{ (image) in
                let event: Event = EventMaper.dictionaryToEvent(eventDictionary: eventDictionary!, image: image)
                 withh(event)
                
            })
        })
    }
    
    func loadParticipantsCount(evetId: Int, withh: @escaping (Int)->Void){
        let eventRef = ref.child("events/"+String(evetId)).observe(.value, with: { (snapshot) in
            let eventDictionary = snapshot.value as? NSDictionary
            let signedUsers = eventDictionary?.value(forKey: "signedUsers") as! Array<Int>
            let count = signedUsers.count
            
                withh(count-1)
            })
    }
    
    func updateContribution(event: Event, sum: Int, withh: @escaping (Int)->Void){
        
        let ownerRef = ref.child("user/" + String(event.ownerId) + "/contributedSum/").observe(.value, with: {(snapshot) in
        var contributionSum = snapshot.value as! Int
            contributionSum = contributionSum + sum
        })
    }
    
    func  addContributionOwner(event: Event, sum: Int) -> Void {
        updateContribution(event: event, sum: sum, withh:{ (newSum) in
    let ownerRef = self.ref.child("user/" + String(event.ownerId) + "/contributedSum/").setValue(newSum)
        })
    }
    
    
    
    
}
