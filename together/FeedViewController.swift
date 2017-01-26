//
//  FeesViewController.swift
//  together
//
//  Created by ASda Bogasd on 17.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var filtersPiker: UIPickerView!
    @IBOutlet var avatarImage: UIButton!
    @IBOutlet weak var myColectionView: UICollectionView!
    
    var pickerData: [String] = [String] ()
    var eventRepositories: EventRepositories!
    var events: Array<Event> = []
    var Events:[Event] = [Event]()
    var userRepositories: UserRepositories!
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var id:Int!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        
        //Load userDefaults
        let defaults = UserDefaults.standard
        id = defaults.integer(forKey: "userId")
        
        pickerData = ["Category","Celebretion", "Helping"]
        
        
        
        
        eventRepositories = EventRepositories()
        eventRepositories.loadAllEvents(withh: {(events)  in
            self.events = events
            self.myColectionView.reloadData()
        })
        
        self.filtersPiker.delegate = self
        self.filtersPiker.dataSource = self
        
        //Load avatar
        self.userRepositories = UserRepositories()
        userRepositories.loadUserImage(id: id, storage: storage, storageRef: storageRef, withh: {(image) in
            self.avatarImage.setImage(image, for: .normal)
        })
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        filterEvents(row:row, type:"category")
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        
        let data = pickerData[row]
        let title = NSAttributedString(string: data, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 10.0, weight: UIFontWeightRegular)])
        
        label?.attributedText = title
        label?.textAlignment = .center
        label?.textColor = UIColor.white
        return label!
    }
    
    //Collection View
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.eventPhoto.image = events[indexPath.row].photo
        cell.eventTitle.text = events[indexPath.row].title
        cell.eventDescription.text = events[indexPath.row].description
        cell.eventCollected.text = String(events[indexPath.row].contrebuted)+"$"
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    //Mark Action
    @IBAction func createButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "fromFeedToCreateEvent", sender: self)
    }
    
    @IBAction func friendsFilterPressed(_ sender: Any) {
         filterEvents(type: "friends")
    }
           
    
    
    func filterEvents(row: Int = 0, type: String) {
        switch type {
        case "category":
            if (row == 0) {
                eventRepositories.loadAllEvents(withh: {(events)  in
                    self.events = events
                    self.myColectionView.reloadData()
                })
            } else {
                eventRepositories.loadCategoryEvents(category: pickerData[row], withh: {(events) in
                    self.events = events
                    self.myColectionView.reloadData()
                })
            }
            case "friends":
                eventRepositories.loadFriendsEvents(id: id, withh:{(events)  in
                    self.events = events
                    self.myColectionView.reloadData()
                })

        default:
            eventRepositories.loadAllEvents(withh: {(events)  in
                self.events = events
                self.myColectionView.reloadData()
            })
        }
        
    }
    
    
    
    
    
    
}
