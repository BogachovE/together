//
//  ViewController.swift
//  together
//
//  Created by ASda Bogasd on 12.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit
import Firebase
import OneSignal



class RegistratonViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var editUserName: UITextField!
    @IBOutlet weak var editPhoneNumber: UITextField!
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editPassword: UITextField!
    @IBOutlet weak var photoEdit: UIImageView!

    
    var ref: FIRDatabaseReference!
    var user: User!
    var userRepositories: UserRepositories!
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
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        underlined()
        self.userRepositories = UserRepositories()
        self.photoEdit.layer.cornerRadius = self.photoEdit.frame.size.width / 2;
        self.photoEdit.clipsToBounds = true;
        self.photoEdit.layer.borderWidth = 1.0
        self.photoEdit.layer.borderColor = UIColor.white.cgColor
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        }
    
  
    @IBAction func donePressed(_ sender: Any) {
        FIRAuth.auth()?.createUser(withEmail: editEmail.text!, password: editPassword.text!, completion: { (user: FIRUser?, error) in
            if error == nil {
                print("successful")
                self.addnewUser()
            }else{
                print("failure" ,error!)
                //registration failure
            }
        })
        
      
    }
    
       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
       func addnewUser(){
        OneSignal.idsAvailable({(_ userId, _ pushToken) in
            print("UserId:\(userId)")
            if pushToken != nil {
                print("pushToken:\(pushToken)")
            }
            self.user = User(name: self.editUserName.text!, email: self.editEmail.text!, phone: self.editPhoneNumber.text!, photo: self.photoEdit.image!, notificationId: userId!)
            self.userRepositories.addnewUser(user: self.user, ref: self.ref, storageRef: self.storageRef, type: "standart")
            self.performSegue(withIdentifier: "fromRegisterToMain", sender: self)
        })
        
    }


}

