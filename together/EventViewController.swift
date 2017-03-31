//
//  EventViewController.swift
//  together
//
//  Created by ASda Bogasd on 21.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit
import Firebase
import KCFloatingActionButton
import MessageUI
import Social



class EventViewController: UIViewController, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, UITableViewDelegate, UITableViewDataSource{
    var eventId: Int = 0
    var storageRef: FIRStorageReference!
    var ref: FIRDatabaseReference!
    var eventRepositories: EventRepositories!
    var userRepositories: UserRepositories!
    var event: Event!
    var fab = KCFloatingActionButton()
    var myId: UInt64!
    var user: User!

    @IBOutlet weak var eventPhoto: UIImageView!
    @IBOutlet weak var eventDataEnd: UILabel!
    @IBOutlet weak var eventDataStart: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventParticipants: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var moreIcon: UIImageView!
    @IBOutlet weak var lessButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var subscribeLabel: UILabel!
    @IBOutlet weak var wishListIcon: UIImageView!
    @IBOutlet weak var wishListTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lessButton.isHidden = true
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        eventRepositories = EventRepositories()
        let defaults = UserDefaults.standard
        myId = defaults.value(forKey: "userId") as! UInt64
        showEventInfo()
        layoutFAB()
        userRepositories = UserRepositories()
        wishListTable.delegate = self
        wishListTable.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showEventInfo(){
        eventRepositories.loadEvent(eventId: eventId, withh:{ (event) in
            self.event = event
            let isLike:Bool = self.checkLike()
            if (isLike){
                self.likeButton.isSelected = true
            }

            self.eventRepositories.loadParticipantsCount(evetId: self.eventId, withh:{ (count) in
                self.event = Event()
                self.event = event
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .medium
                let startTimeString = formatter.string(from: event.startTime)
                let endTimeString = formatter.string(from: event.endTime)
                
                self.eventDataStart.text = startTimeString
                self.eventDataEnd.text = endTimeString
                self.eventLocation.text = event.location
                self.eventPhoto.image = event.photo
                self.eventTitle.text = event.title
                self.eventParticipants.text = String(count)
                self.eventDescription.text = event.description
                
                self.userRepositories.loadUser(userId: UInt64(self.myId), withh: { (user) in
                    //maybe do func
                    self.user = user
                    for i in user.signedEvent {
                        if (i == event.id){
                            self.subscribeLabel.text = "Unsubscrible"
                        } else {
                            self.subscribeLabel.text = "Subscrible"
                        }
                    }
                    self.wishListTable.reloadData()
                })
            })
        })
    }
    
    func layoutFAB() {
        fab.buttonColor = UIColor(red:0.41, green:0.94, blue:0.68, alpha:1.0)
        fab.plusColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        let titles: Array<String> = ["Share to facebook", "Share by email", "Share to instagram", "Share to twiter"]
        let types: Array<String> = ["face", "email", "incta", "twiter"]
        let icons: Array<UIImage> = [#imageLiteral(resourceName: "faceBtn"),#imageLiteral(resourceName: "EmailBtn"), #imageLiteral(resourceName: "inctaBtn"), #imageLiteral(resourceName: "twiterBtn")]
        for i in 0...3{
            let item = KCFloatingActionButtonItem()
            item.buttonColor = UIColor(red:0.41, green:0.94, blue:0.68, alpha:1.0)
            item.circleShadowColor = UIColor.red
            item.titleShadowColor = UIColor.blue
            item.icon = icons[i]
            item.title = titles[i]
            item.handler = { item in
                if #available(iOS 10.0, *) {
                    self.share(type: types[i])
                } else {
                    // Fallback on earlier versions
                }
            }
            fab.addItem(item: item)
        }
        
        fab.sticky = true
        
        
        self.view.addSubview(fab)
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width:size.width * heightRatio, height:size.height * heightRatio)
        } else {
            newSize = CGSize(width:size.width * widthRatio,  height:size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0,width: newSize.width,height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @available(iOS 10.0, *)
    func share(type: String){
        switch (type) {
        case "face":
            shareFace(event:event)
        case "email":
            shareByEmail(event: event)
        case "wat":
            SocialShare.whatsappShare(event:event)
        case "incta":
            InstagramManager.sharedManager.postImageToInstagramWithCaption(imageInstagram:event.photo, instagramCaption: "\(event.description)", view: self.view)
            case "twiter":
            shareTwit(event: event)
            
        default :
            print("Switch error")
        }
    }
    
     func shareByEmail(event: Event){
        let mailComposeViewController = configuredMailComposeViewController(event: event)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    func configuredMailComposeViewController(event: Event) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        

        mailComposerVC.setSubject("Email from Together")
        mailComposerVC.setMessageBody("Hi I want to show you something", isHTML: false)
    
        let data = UIImagePNGRepresentation(event.photo) as NSData?
        
        mailComposerVC.addAttachmentData(data as! Data, mimeType: "hz", fileName: "event.jpg")
        
        
        return mailComposerVC
    }
        
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    func shareFace(event: Event){
        if let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
            vc.setInitialText("Look at this great picture!")
            vc.add(event.photo)
            vc.add(URL(string: "https://www.hackingwithswift.com"))
            present(vc, animated: true)
        }

    }
    func shareTwit(event: Event){
        if let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
            vc.setInitialText("Look at this great picture!")
            vc.add(event.photo)
            vc.add(URL(string: "https://www.hackingwithswift.com"))
            present(vc, animated: true)
        }
        
    }

    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "fromEventToContribut") {
            let svc = segue.destination as! ContributionViewController
            
            svc.event = event
            
        }
    }

   
    func checkLike() -> Bool {
        var isLiked: Bool
        isLiked = false
        for i in event.likes{
            if (i == myId) {
                isLiked = true
                print("i=",i)
            }
        }
        print("eventId=", String(event.id),"isLiked", isLiked)
        return isLiked
    }
    
    func removeLike(){
        let likesQuery = ref.child("events/"+String(event.id)+"/likes").queryOrderedByValue().queryEqual(toValue: myId)
        likesQuery.observe(.value, with: { (snapshot) in
            for i in snapshot.children{
                let  snapy = i as! FIRDataSnapshot
                if (snapshot.exists()){
                    self.ref.child("events/"+String(self.event.id)+"/likes/"+String(snapy.key)+"/").removeValue()
                    likesQuery.removeAllObservers()
                }
            }
            self.likeButton.isSelected = false
        })
    }
    
    func addLike(){
        let notificationRepositories = NotificationRepositories()
        notificationRepositories.likeNotification(event: self.event, user: user, myId: myId)
        let likeRef = ref.child("events/"+String(self.event.id)+"/likes/")
        likeRef.observeSingleEvent(of: .value, with: { (snaphot) in
            likeRef.child(String(snaphot.childrenCount)).setValue(self.myId)
            self.likeButton.isSelected = true
        })
    }
    
    
    //table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int
        if (event != nil) {
            count = event.linkStrings.count
        } else {
            count = 3
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = wishListTable.dequeueReusableCell(withIdentifier: "eventTableviewcell", for: indexPath) as! WishListTableViewCell
        if (event != nil){
            cell.link.setTitle(event.linkStrings[indexPath.row], for: .normal)
        } else {
            cell.link.setTitle("", for: .normal)
        }
        
        cell.checkbox.tag = indexPath.row
        cell.checkbox.addTarget(self, action: #selector(self.checkclicked(sender:)), for: UIControlEvents.touchUpInside)
        cell.link.tag = indexPath.row
        cell.link.addTarget(self, action: #selector(self.linkclicked(sender:)), for: UIControlEvents.touchUpInside)

        
        if (event != nil) {
            if (event.linkDone[indexPath.row] == 0){
            cell.checkbox.isSelected = false
            } else {
                cell.checkbox.isSelected = true
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

 

    
    //Actions
    func linkclicked(sender: UIButton) {
        let url = NSURL(string: event.linkUrls[sender.tag]) as! URL
        print(url)
        UIApplication.shared.openURL(url)
    }
    
    func checkclicked(sender: UIButton) {

        if(event != nil) {
            if (event.linkDone[sender.tag] == 0){
                event.linkDone[sender.tag] = myId
            } else if (event.linkDone[sender.tag] == myId) {
                event.linkDone[sender.tag] = 0
            }
            wishListTable.reloadData()
        }
        

    }
    
    @IBAction func moreButtonPressed(_ sender: Any) {
        likeButton.isHidden = true
        moreIcon.isHidden = true
        lessButton.isHidden = false
        lessButton.isEnabled = true
        moreButton.isHidden = true
        eventDescription.isHidden = false
        wishListIcon.isHidden = true
        wishListTable.isHidden = true
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        if (event != nil && user != nil){
            let isLike:Bool = self.checkLike()
            if (isLike){
                removeLike()
                likeButton.isSelected = false
            } else {
                addLike()
                likeButton.isSelected = true
            }
        }
    }
    
    @IBAction func lessPres(_ sender: Any) {
        likeButton.isHidden = false
        moreIcon.isHidden = false
        lessButton.isHidden = true
        lessButton.isEnabled = false
        moreButton.isHidden = false
        eventDescription.isHidden = true
        wishListIcon.isHidden = false
        wishListTable.isHidden = false
    }
    
    @IBAction func subscribeButtonPressed(_ sender: Any) {
        if (event != nil && user != nil) {
            if (subscribeLabel.text == "Unsubscrible"){
                let uscribeIndex = user.signedEvent.index(of: event.id)
                user.signedEvent.remove(at: uscribeIndex!)
                ref.child("users/" + String(myId) + "/signedEvent/").setValue(user.signedEvent)
                let uscribeEventIndex = event.signedUsers.index(of: myId)
                event.signedUsers.remove(at: uscribeEventIndex!)
                ref.child("events/" + String(event.id) + "/signedUsers/").setValue(event.signedUsers)
                
            } else {
                user.signedEvent.append(event.id)
                ref.child("users/" + String(myId) + "/signedEvent/").setValue(user.signedEvent)
                event.signedUsers.append(myId)
                ref.child("events/" + String(event.id) + "/signedUsers/").setValue(event.signedUsers)
            }
        }
    }
    
    
    

    
}
