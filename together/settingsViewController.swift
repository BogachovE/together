//
//  settingsViewController.swift
//  together
//
//  Created by ASda Bogasd on 24.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit
import Firebase

class settingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var photo: UIImageView!
    @IBOutlet var editDescription: UITextField!
    @IBOutlet var editTitle: UITextField!
    @IBOutlet var editEmail: UITextField!
    @IBOutlet var editPassword: UITextField!
    @IBOutlet var editPhoneNumber: UITextField!
    @IBOutlet var editUserName: UITextField!
    
    var myId: Int = 0
    var ref: FIRDatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        //Load userDefaults
        let defaults = UserDefaults.standard
        myId = defaults.integer(forKey: "userId")

        // Do any additional setup after loading the view.
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
        photo.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func userUpdate(){
        let userRepositories:UserRepositories = UserRepositories()
        userRepositories.loadUser(userId: myId, withh: { (user) in
            let newUser: User
            newUser = user
            if(self.editUserName.text! != ""){newUser.name = self.editUserName.text!}
            if(self.editDescription.text! != ""){newUser.description = self.editDescription.text!}
            if(self.editTitle.text! != ""){newUser.title = self.editTitle.text!}
            if(self.editEmail.text! != ""){newUser.email = self.editEmail.text!}
            if (self.editEmail.text != ""){
            FIRAuth.auth()?.currentUser?.updateEmail(self.editEmail.text!) { (error) in
                // ...
                if (error != nil){ print("ERRORCHANGEEMAIL =", error!)}
            }
            }
            if (self.editPassword.text != ""){
            FIRAuth.auth()?.currentUser?.updatePassword(self.editPassword.text!) { (error) in
                // ...
                if (error != nil){ print("ERRORCHANGEPASSWORD =", error!)}
            }
            }
            if(self.editPhoneNumber.text! != ""){newUser.phone = self.editPhoneNumber.text!}
            //if(photo.image! != photo.image){newUser.name = photo.image!}
            //if(editPassword.text! != ""){newUser. = editPassword.text!}
            let userDictionary = UserMaper.userToDictionary(user: newUser)
            self.ref.child("users/" + String(self.myId)).setValue(userDictionary)
            userRepositories.uploadUserImage(userId: user.id, image: self.photo.image!)
        })
        
        
    }
    
    //Actions
    @IBAction func logOutPressed(sender: AnyObject) {
        let defaults = UserDefaults.standard
        
        if let bundle = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: "com.togetherr")
            defaults.synchronize()
        }
        self.performSegue(withIdentifier: "fromSettingsToLogin", sender: self)
    }

    @IBAction func editPhotoPressed(sender: AnyObject) {
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
   
    @IBAction func saveButttonPressed(sender: AnyObject) {
        userUpdate()
        self.performSegue(withIdentifier: "fromSettingsToFeed", sender: self)
    }
    
    

}
