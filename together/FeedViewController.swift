//
//  FeesViewController.swift
//  together
//
//  Created by ASda Bogasd on 17.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit


class FeedViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var filtersPiker: UIPickerView!
    
    var pickerData: [String] = [String] ()
    var eventRepositories: EventRepositories!
    var events: Array<Event> = []
    var Events:[Event] = [Event]()

    @IBOutlet weak var myColectionView: UICollectionView!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        eventRepositories = EventRepositories()
        eventRepositories.loadAllEvents(withh: {(events)  in
           self.events = events
            self.myColectionView.reloadData()
        })
                // Connect data:
        self.filtersPiker.delegate = self
        self.filtersPiker.dataSource = self
        myColectionView.reloadData()
        
        pickerData = ["Category","Celebretion", "Helping"]
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
    
    
    
    
    
    
    
}
