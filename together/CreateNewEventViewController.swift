//
//  CreateNeEventViewController.swift
//  
//
//  Created by ASda Bogasd on 21.01.17.
//
//

import UIKit
import Firebase
import

class CreateNewEventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UINavigationControllerDelegate,  UIImagePickerControllerDelegate {

    @IBOutlet var dataStartPicker: UIDatePicker!
    @IBOutlet var dataEndPicker: UIDatePicker!
    @IBOutlet var editLoaction: UITextField!
    @IBOutlet var editDescription: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var photoEdit: UIImageView!
    @IBOutlet var editTitle: UITextField!
    
    var selectedCategory: String!
    var pickerData: [String] = []
    var event: Event = Event()
     var id:Int!
    var storageRef: FIRStorageReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        
        let defaults = UserDefaults.standard
        id = defaults.integer(forKey: "userId")
        
        selectedCategory = "none"
        pickerData = ["Celebrating", "Helping"]
        
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        
        
        
        // Do any additional setup after loading the view.
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
    
    //Actions
    @IBAction func doneButtonPressed(sender: AnyObject) {
        let eventRepositories = EventRepositories()
        eventRepositories.loadEventCount(withh:{ (count) in
            if (self.selectedCategory != "none"){
                self.event = Event(title: self.editTitle.text!, description: self.editDescription.text!, id: count, photo: self.photoEdit.image!
                    , category: self.selectedCategory, ownerId: self.id, location: self.editLoaction.text!, startTime: self.dataStartPicker.date, endTime: self.dataEndPicker.date)
                eventRepositories.addNewEvent(event: self.event, count: count, storageRef: self.storageRef)
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

    
    

    }
