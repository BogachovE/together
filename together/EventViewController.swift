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



class EventViewController: UIViewController, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate{
    var eventId: Int = 0
    var storageRef: FIRStorageReference!
    var ref: FIRDatabaseReference!
    var eventRepositories: EventRepositories!
    var event: Event!
    var fab = KCFloatingActionButton()

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lessButton.isHidden = true
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        eventRepositories = EventRepositories()
        showEventInfo()
        layoutFAB()
        
        
    
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showEventInfo(){
        eventRepositories.loadEvent(eventId: eventId, withh:{ (event) in
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
            })
        })
    }
    
    func layoutFAB() {
                fab.buttonColor = UIColor(red:0.41, green:0.94, blue:0.68, alpha:1.0)
        fab.plusColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        let titles: Array<String> = ["Share to whatsapp", "Share to facebook", "Share to snapchat", "Share by email", "Share to instagram", "Share to twiter"]
        let types: Array<String> = ["wat", "face", "snap", "email", "incta", "twiter"]
        let icons: Array<UIImage> = [#imageLiteral(resourceName: "watBtn"), #imageLiteral(resourceName: "faceBtn"), #imageLiteral(resourceName: "snapBtn"),#imageLiteral(resourceName: "EmailBtn"), #imageLiteral(resourceName: "inctaBtn"), #imageLiteral(resourceName: "twiterBtn")]
        for i in 0...5{
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
    
    

 

    
    //Actions
    @IBAction func moreButtonPressed(_ sender: Any) {
        likeButton.isHidden = true
        moreIcon.isHidden = true
        lessButton.isHidden = false
        lessButton.isEnabled = true
        moreButton.isHidden = true
        eventDescription.isHidden = false
    }
    
    
    @IBAction func lessPres(_ sender: Any) {
        likeButton.isHidden = false
        moreIcon.isHidden = false
        lessButton.isHidden = true
        lessButton.isEnabled = false
        moreButton.isHidden = false
        eventDescription.isHidden = true
    }
    
    
    

    
}
