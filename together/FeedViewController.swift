//
//  FeesViewController.swift
//  together
//
//  Created by ASda Bogasd on 17.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var filtersPiker: UIPickerView!
    @IBOutlet var avatarImage: UIButton!
    @IBOutlet weak var myColectionView: UICollectionView!
    @IBOutlet weak var loginView: UILabel!
    @IBOutlet weak var mySerchBar: UISearchBar!
    @IBOutlet weak var myColectionViewHeight: NSLayoutConstraint!
   
    
    var pickerData: [String] = [String] ()
    var eventRepositories: EventRepositories!
    var events: Array<Event> = []
    var Events:[Event] = [Event]()
    var userRepositories: UserRepositories!
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var id:UInt64!
    var buttonState: Array<Bool> = []
    var filterType: String = "all"
    var searchActive : Bool = false
    var selectedEvent: Int = 0

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width / 2;
        self.avatarImage.clipsToBounds = true;
        self.avatarImage.layer.borderWidth = 1.0
        self.avatarImage.layer.borderColor = UIColor.white.cgColor
        
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        //Load userDefaults
        let defaults = UserDefaults.standard
        id = defaults.value(forKey: "userId") as! UInt64
        pickerData = ["Category","Celebretion", "Helping"]
        
        eventRepositories = EventRepositories()
        
        
        self.filtersPiker.delegate = self
        self.filtersPiker.dataSource = self
        self.mySerchBar.delegate = self
        
        filterType = "all"
        filterEvents(type: filterType)
        
        mySerchBar.isHidden = true
        
        //Load avatar and Login
        self.userRepositories = UserRepositories()
        userRepositories.loadUserImage(id: UInt64(id), storage: storage, storageRef: storageRef, withh: {(image) in
            self.avatarImage.setImage(image, for: .normal)
        })
        userRepositories.loadLogin(id:id, withh: {(name) in
            self.loginView.text = name
        })
        
        mySerchBar.isHidden = true
       // self.myColectionViewHeight.constant = 489
        
        
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchActive == false){
            filterEvents(type: "hashtag", searchText:searchText)
        }
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
        mySerchBar.isHidden = true
        //self.myColectionViewHeight.constant = 489
        self.myColectionView.layoutIfNeeded()

        filterType = "category"
        filterEvents(row:row, type: filterType)
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
        for i in events[indexPath.row].likes {
            if (UInt64(i) == id){
             cell.likeButton.isSelected = true
            }else {
              cell.likeButton.isSelected = false
            }
        }
        
        
        cell.eventPhoto.image = events[indexPath.row].photo
        cell.eventTitle.text = events[indexPath.row].title
        cell.eventDescription.text = events[indexPath.row].description
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        
        
        
        return cell
    }
    
    func buttonClicked(sender: UIButton) {
        var isLiked: Bool
        isLiked = checkLike(sender: sender)
        if (isLiked == true){
            removeLike(sender: sender)
                    } else {
            addLike(sender: sender)
        }
        self.myColectionView.reloadData()
        filterEvents(type: filterType)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedEvent = indexPath.row
       self.performSegue(withIdentifier: "fromFeedToEvent", sender: self)
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        
    }
    
    

    
    
    //Mark Action
    @IBAction func createButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "fromFeedToCreateEvent", sender: self)
    }
    
    @IBAction func friendsFilterPressed(_ sender: Any) {
        mySerchBar.isHidden = true
        //self.myColectionViewHeight.constant = 489
        self.myColectionView.layoutIfNeeded()

        filterType = "friends"
        filterEvents(type: filterType)
    }
           
    @IBAction func myEventPressed(_ sender: Any) {
        mySerchBar.isHidden = true
        //self.myColectionViewHeight.constant = 489
        self.myColectionView.layoutIfNeeded()

        filterType = "my"
        filterEvents(type: filterType)
    }
    
    @IBAction func signedEventPressed(_ sender: Any) {
        mySerchBar.isHidden = true
        //self.myColectionViewHeight.constant = 489
        self.myColectionView.layoutIfNeeded()
        filterType = "signed"
        filterEvents(type: filterType)
    }
    
    @IBAction func HashTagPressed(_ sender: Any) {
        mySerchBar.isHidden = false
        //self.myColectionViewHeight.constant = 459
        self.myColectionView.layoutIfNeeded()
    }
    
    
    
    func filterEvents(row: Int = 0, type: String, searchText: String = "") {
        switch type {
        case "all":
            mySerchBar.isHidden = true
            //self.myColectionViewHeight.constant = 489
            eventRepositories.loadAllEvents(withh: {(events)  in
                self.events = events
                self.myColectionView.reloadData()
            })
            
        case "category":
            if (row == 0) {
                events.removeAll()
                eventRepositories.loadAllEvents(withh: {(events)  in
                    self.events = events
                    self.myColectionView.reloadData()
                })
            } else {
                events.removeAll()
                eventRepositories.loadCategoryEvents(category: pickerData[row], withh: {(events) in
                    self.events = events
                    self.myColectionView.reloadData()
                })
            }
            case "friends":
                events.removeAll()
                eventRepositories.loadFriendsEvents(id: id, withh:{(events)  in
                    self.events = events
                    self.myColectionView.reloadData()
                })
            case "my":
                events.removeAll()
                eventRepositories.loadMyEvents(id: id, withh:{(events) in
                    self.events = events
                    self.myColectionView.reloadData()
                })
            case "signed":
                events.removeAll()
                eventRepositories.loadSignedEvents(id: id, withh:{(events) in
                    self.events = events
                    self.myColectionView.reloadData()
                })
            case "hashtag":
                events.removeAll()
                eventRepositories.loadEventByHashtag(searchText: searchText, withh:{(events) in
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
    
    func checkLike(sender: UIButton) -> Bool {
        var isLiked: Bool
        isLiked = false
        for i in events[sender.tag].likes{
            if (UInt64(i) == id) {
                isLiked = true
                print("i=",i)
            }
        }
        
        print("eventId=", String(events[sender.tag].id),"isLiked", isLiked)
        
        return isLiked
    }
    
    func removeLike(sender: UIButton){
        let likesQuery = ref.child("events/"+String(events[sender.tag].id)+"/likes").queryOrderedByValue().queryEqual(toValue: id)
        likesQuery.observe(.value, with: { (snapshot) in
            for i in snapshot.children{
                let  snapy = i as! FIRDataSnapshot
                if (snapshot.exists()){
                    self.ref.child("events/"+String(self.events[sender.tag].id)+"/likes/"+String(snapy.key)+"/").removeValue()
                    likesQuery.removeAllObservers()
                }
            }
            self.myColectionView.reloadData()
        })
    }
    
    func addLike(sender: UIButton){
        
        self.userRepositories.loadUser(userId: UInt64(id), withh:{ (user) in
            let notificationRepositories = NotificationRepositories()
            notificationRepositories.likeNotification(event: self.events[sender.tag], user: user, myId:self.id)
            
        })
        
        let likeRef = ref.child("events/"+String(self.events[sender.tag].id)+"/likes/")
        likeRef.observeSingleEvent(of: .value, with: { (snaphot) in
            likeRef.child(String(snaphot.childrenCount)).setValue(self.id)
            self.myColectionView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "fromFeedToEvent") {
            let svc = segue.destination as! EventViewController
            
            svc.eventId = events[selectedEvent].id
            
        } else if (segue.identifier == "fromFeedToProfile"){
            let svc = segue.destination as! ProfileViewController
            
            svc.userId = self.id
        }
    }
    
    
}
