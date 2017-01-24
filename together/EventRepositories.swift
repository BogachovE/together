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
    
}
