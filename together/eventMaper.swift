//
//  eventMaper.swift
//  together
//
//  Created by ASda Bogasd on 29.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation

class EventMaper{
    
    
    static func eventToDictionary(event: Event) ->NSDictionary  {
        let dictionaryEvent: NSDictionary
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let startTimeString = formatter.string(from: event.startTime)
        let endTimeString = formatter.string(from: event.endTime)
        dictionaryEvent = ["id":event.id, "title":event.title, "description":event.description, "contrebuted":event.contrebuted, "category":event.category, "ownerId":event.ownerId, "likes":event.likes, "location":event.location, "startTime":startTimeString, "endTime": endTimeString]
        return dictionaryEvent
    }
    
    static func dictionaryToEvent(eventDictionary: NSDictionary,image:UIImage) ->Event {
        let event: Event
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy, h:mm"
        //dateFormatter.dateStyle = DateFormatter.Style.MediumStyle
       
        event = Event(title: eventDictionary.value(forKey: "title") as! String, description: eventDictionary.value(forKey: "description") as! String, id: eventDictionary.value(forKey: "id") as! Int, contrebuted: eventDictionary.value(forKey: "contrebuted") as! Int, category: eventDictionary.value(forKey: "category") as! String, ownerId: eventDictionary.value(forKey: "ownerId") as! Int, likes: eventDictionary.value(forKey: "likes") as! Array<Int>, location: eventDictionary.value(forKey: "location") as! String)
        return event
    }
    
    
}
