//
//  ViewController.swift
//  together
//
//  Created by ASda Bogasd on 12.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit
import Firebase



class RegistratonViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var editUserName: UITextField!
    @IBOutlet weak var editPhoneNumber: UITextField!
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editPassword: UITextField!
    @IBOutlet weak var photoEdit: UIImageView!

    
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var count: Int!
    var userId : AnyObject? {
        get {
            return UserDefaults.standard.object(forKey: "userId") as AnyObject?
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userId")
            UserDefaults.standard.synchronize()
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        underlined()
        self.photoEdit.layer.cornerRadius = self.photoEdit.frame.size.width / 2;
        self.photoEdit.clipsToBounds = true;
        self.photoEdit.layer.borderWidth = 1.0
        self.photoEdit.layer.borderColor = UIColor.white.cgColor
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        }
    
  
    
       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   @IBAction func donePresed(_ sender: Any) {
        addnewUser()
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

    
    func underlined(){
        let borderBottom = CALayer()
        let borderBottom2 = CALayer()
        let borderBottom3 = CALayer()
        let borderBottom4 = CALayer()
        let borderWidth = CGFloat(2.0)
       
        borderBottom.borderColor = UIColor.gray.cgColor
        borderBottom.frame = CGRect(x: 0, y: editUserName.frame.height - 1.0, width: editUserName.frame.width , height: editUserName.frame.height - 1.0)
        borderBottom.borderWidth = borderWidth
        
        borderBottom2.borderColor = UIColor.gray.cgColor
        borderBottom2.frame = CGRect(x: 0, y: editUserName.frame.height - 1.0, width: editUserName.frame.width , height: editUserName.frame.height - 1.0)
        borderBottom2.borderWidth = borderWidth
        
        borderBottom3.borderColor = UIColor.gray.cgColor
        borderBottom3.frame = CGRect(x: 0, y: editUserName.frame.height - 1.0, width: editUserName.frame.width , height: editUserName.frame.height - 1.0)
        borderBottom3.borderWidth = borderWidth

        borderBottom4.borderColor = UIColor.gray.cgColor
        borderBottom4.frame = CGRect(x: 0, y: editUserName.frame.height - 1.0, width: editUserName.frame.width , height: editUserName.frame.height - 1.0)
        borderBottom4.borderWidth = borderWidth

        
        editUserName.layer.addSublayer(borderBottom2)
        editUserName.layer.masksToBounds = true
        editEmail.layer.addSublayer(borderBottom3)
        editEmail.layer.masksToBounds = true
        editPassword.layer.addSublayer(borderBottom4)
        editPassword.layer.masksToBounds = true
        editPhoneNumber.layer.addSublayer(borderBottom)
        editPhoneNumber.layer.masksToBounds = true
    }
    
    @IBAction func editPhotoPresed(_ sender: UITapGestureRecognizer) {
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
    func addnewUser(){
       //find actual count of users
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.count = value?["count"] as? NSInteger
            let id: Int
            if (self.count != nil){
                id = self.count+1
            } else{
                id = 1
            }
            let newUser: NSDictionary = ["name":self.editUserName.text!, "email":self.editEmail.text!, "password":self.self.editPassword.text!, "phone":self.editPhoneNumber.text!, "id":id]
        //Store UserId
            self.userId = id as AnyObject?
            
        //Put image
            // Data in memory
            let data = UIImagePNGRepresentation(self.photoEdit.image!)
            
            // Create a reference to the file you want to upload
            let riversRef = self.storageRef.child("avatars/"+String(id)+".jpg")
            
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef.put(data!, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL
            }
        //Put data to dataBase
            self.ref.child("users").child(String(id)).setValue(newUser)
            self.ref.child("users").child("count").setValue(id)
            
        }) { (error) in
            print(error.localizedDescription)
            }
    }


}

