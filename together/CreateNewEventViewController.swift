//
//  CreateNeEventViewController.swift
//  
//
//  Created by ASda Bogasd on 21.01.17.
//
//

import UIKit
import Firebase
import KCFloatingActionButton
import Social
import MessageUI

class CreateNewEventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UINavigationControllerDelegate,  UIImagePickerControllerDelegate,MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var dataStartPicker: UIDatePicker!
    @IBOutlet var dataEndPicker: UIDatePicker!
    @IBOutlet var editLoaction: UITextField!
    @IBOutlet var editDescription: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var photoEdit: UIImageView!
    @IBOutlet var editTitle: UITextField!
    @IBOutlet weak var wishListTable: UITableView!
    
    var selectedCategory: String!
    var pickerData: [String] = []
    var event: Event = Event()
     var id:Int!
    var storageRef: FIRStorageReference!
    var fab = KCFloatingActionButton()
    var linkCount: Int! = 2
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        
        let defaults = UserDefaults.standard
        id = defaults.integer(forKey: "userId")
        
        selectedCategory = "none"
        pickerData = ["Celebrating", "Helping"]
        
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        
        wishListTable.delegate = self
        wishListTable.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func layoutFAB() {
        fab.buttonColor = UIColor(red:0.41, green:0.94, blue:0.68, alpha:1.0)
        fab.plusColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        let titles: Array<String> = ["Share to whatsapp", "Share to facebook", "Share by email", "Share to instagram", "Share to twiter"]
        let types: Array<String> = ["wat", "face", "email", "incta", "twiter"]
        let icons: Array<UIImage> = [#imageLiteral(resourceName: "watBtn"), #imageLiteral(resourceName: "faceBtn"),#imageLiteral(resourceName: "EmailBtn"), #imageLiteral(resourceName: "inctaBtn"), #imageLiteral(resourceName: "twiterBtn")]
        for i in 0...4{
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
        selectedCategory = pickerData[row]
        
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
        label?.font = UIFont.boldSystemFont(ofSize: 10)
        return label!
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = wishListTable.dequeueReusableCell(withIdentifier: "tableviewcell", for: indexPath) as! WishListTableViewCell
        cell.link.text = "Tshort"
        
        cell.pluseButton.addTarget(self, action: #selector(self.pluseclicked(sender:)), for: UIControlEvents.touchUpInside)
        
        if (indexPath.row == linkCount - 1){
            //cell.pluseButton.isHidden = false
        } else {
            cell.pluseButton.setTitle("-", for: .normal)
        }
        
        
        
        return cell
    }

    
    
    
    //Actions
    
    func pluseclicked(sender: UIButton) {
        if (sender.title(for: .normal) == "+"){
        linkCount = linkCount + 1
        wishListTable.reloadData()
        } else {
            linkCount = linkCount - 1
            wishListTable.reloadData()
        }
        
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        let eventRepositories = EventRepositories()
        eventRepositories.loadEventCount(withh:{ (count) in
            if (self.selectedCategory != "none"){
                self.event = Event(title: self.editTitle.text!, description: self.editDescription.text!, id: count, photo: self.photoEdit.image!
                    , category: self.selectedCategory, ownerId: UInt64(self.id), location: self.editLoaction.text!, startTime: self.dataStartPicker.date, endTime: self.dataEndPicker.date)
                eventRepositories.addNewEvent(event: self.event, count: count, storageRef: self.storageRef)
                self.layoutFAB()
                self.makeToast(text: "Do you want to share your event?")
                self.fab.open()
            } else {
                self.makeToast(text: "Please select category")
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoEdit.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editPhotoPressed(_ sender: Any) {
        // Hide the keyboard.
        //        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func makeToast(text: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center;
        self.view.addSubview(toastLabel)
        toastLabel.text = text
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        UIView.animate(withDuration: 4.0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            toastLabel.alpha = 0.0
        })
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
}
