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
import StoreKit
import AMGCalendarManager
import GooglePlacePicker

class CreateNewEventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UINavigationControllerDelegate,  UIImagePickerControllerDelegate,MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate,
SKPaymentTransactionObserver {

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
     var id:UInt64!
    var storageRef: FIRStorageReference!
    var fab = KCFloatingActionButton()
    var linkCount: Int! = 2
    var url: String!
    var urlString: String!
    
    /* Variables */
    let COINS_PRODUCT_ID = "com.products.attractive.togetherr.wish"
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
   
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        
        let defaults = UserDefaults.standard
        id = defaults.value(forKey: "userId") as! UInt64
        
        selectedCategory = "none"
        pickerData = ["Celebrating", "Helping"]
        
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        editLoaction.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin)
        wishListTable.delegate = self
        wishListTable.dataSource = self
        
       
        
        
        
        // Fetch IAP Products available
        fetchAvailableProducts()
        
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
        let count: Int
        if (event.linkUrls.count != 0){
            if (event.linkUrls[0] == ""){
            count = 1
            } else {
            count = event.linkUrls.count + 1
            }
        } else {
            count = 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = wishListTable.dequeueReusableCell(withIdentifier: "tableviewcell", for: indexPath) as! WishListTableViewCell
        
        
        if (event.linkUrls.count != 0){
            if (indexPath.row == 0){
                if (event.linkUrls[0] != ""){
                    cell.pluseButton.setTitle("-", for: .normal)
                    cell.link.setTitle(event.linkStrings[indexPath.row], for: .normal)
                } else {
                    cell.pluseButton.setTitle("+", for: .normal)
                    cell.link.setTitle("", for: .normal)

                }
            } else if (indexPath.row == event.linkUrls.count) {
                cell.link.setTitle("", for: .normal)
                cell.pluseButton.setTitle("+", for: .normal)
            } else {
                cell.pluseButton.setTitle("-", for: .normal)
                cell.link.setTitle(event.linkStrings[indexPath.row], for: .normal)
            }
        } else {
            cell.link.setTitle("", for: .normal)
            cell.pluseButton.setTitle("+", for: .normal)
        }
        
        cell.pluseButton.tag = indexPath.row
        cell.pluseButton.addTarget(self, action: #selector(self.pluseclicked(sender:)), for: UIControlEvents.touchUpInside)

        
        return cell
    }

    
    
    
    //Actions
    
    func pluseclicked(sender: UIButton) {
        if (sender.title(for: .normal) == "+"){
            
            let alert = UIAlertController(title: "Add wishes", message: "Plese enter your wishes", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            alert.addTextField { (url) in
                url.placeholder = "Enter URL"
            }
            alert.addTextField { (urlString) in
                urlString.placeholder = "Enter name of your wishes"
            }
            self.present(alert, animated: true, completion: nil)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                switch action.style{
                case .default:
                    self.url = alert.textFields![0].text
                    self.urlString = alert.textFields![1].text
                    self.purchaseMyProduct(product: self.iapProducts[0])
                    
                print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                }
            }))

        } else {
            print(sender.tag)
            event.linkStrings.remove(at: sender.tag)
            event.linkUrls.remove(at: sender.tag)
            wishListTable.reloadData()
        }
        
    }
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts()  {
        if SKPaymentQueue.canMakePayments() {
            print("Покупки доступны")
            
            let productID: Set<String> = ["com.products.attractive.togetherr.wish"]
            let request = SKProductsRequest(productIdentifiers: productID)
            request.delegate = self
            request.start()
        } else {
            print("Покупки не доступны")
        }
    }
    
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        print("Product request phase")
        
        print(response.invalidProductIdentifiers)
        
        let myProduct = response.products
        self.iapProducts.append(myProduct[0])
        
        for product in myProduct {
            print("Товар добавлен")
            print("Идентификатор продукта: \(product.productIdentifier)")
            print("\(product.localizedTitle)")
            print("\(product.localizedDescription)")
            }
            
        
    }
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
            
            
            // IAP Purchases dsabled on the Device
        } else {
            UIAlertView(title: "IAP Tutorial",
                        message: "Purchases are disabled in your device!",
                        delegate: nil, cancelButtonTitle: "OK").show()
        }
    }

    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                    
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    // The Consumable product (10 coins) has been purchased -> gain 10 extra coins!
                    if productID == COINS_PRODUCT_ID {
                        
                    
                            self.event.linkUrls.append(self.url!)
                            self.event.linkStrings.append(self.urlString!)
                        
                        self.wishListTable.reloadData()

                        
                        UIAlertView(title: "Successfully",
                                    message: "You've successfully add wishes",
                                    delegate: nil,
                                    cancelButtonTitle: "OK").show()
                    }
                    break
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }}}
    }
    
    func makeNewCalendarMark(date: Date, title: String, notes: String){
        AMGCalendarManager.shared.createEvent(completion: { (event) in
            guard let event = event else { return }
            
            event.startDate = date
            event.endDate = event.startDate.addingTimeInterval(60 * 60 * 1) // 1 hour
            event.title = title
            event.notes = notes
            
            AMGCalendarManager.shared.saveEvent(event: event)
        })
    }
    func textFieldDidChange(_ textField: UITextField){
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePicker(config: config)
        
        placePicker.pickPlace(callback: { (place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place selected")
                return
            }
            
            print("Place name \(place.name)")
            print("Place address \(place.formattedAddress)")
            print("Place attributions \(place.attributions)")
            self.editLoaction.text = place.formattedAddress
        })
    }

    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        let eventRepositories = EventRepositories()
        eventRepositories.loadEventCount(withh:{ (count) in
            if (self.selectedCategory != "none"){
                let newEvent = Event(title: self.editTitle.text!,
                                   description: self.editDescription.text!,
                                   id: count,
                                   photo: self.photoEdit.image!,
                                   category: self.selectedCategory,
                                   ownerId: self.id,
                                   location: self.editLoaction.text!,
                                   startTime: self.dataStartPicker.date,
                                   linkUrls: self.event.linkUrls,
                                   linkStrings: self.event.linkStrings)
                eventRepositories.addNewEvent(event: newEvent, count: count, storageRef: self.storageRef)
               // self.layoutFAB()
             //   self.makeToast(text: "Do you want to share your event?")
              //  self.fab.open()
                self.makeNewCalendarMark(date: newEvent.startTime, title: newEvent.title, notes: newEvent.description)
                self.performSegue(withIdentifier: "fromCreateToFeed", sender: self)
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
