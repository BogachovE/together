//
//  LoginViewController.swift
//  together
//
//  Created by ASda Bogasd on 15.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordEdit: UITextField!
    @IBOutlet weak var userNameEdit: UITextField!
    @IBOutlet weak var rememberMe: UIButton!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        underlined()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donePressed(_ sender: Any) {
        standartLogin()
    }
    @IBAction func rememberMePressed(_ sender: Any) {
        if (rememberMe.isSelected == true) {
            rememberMe.isSelected = false
        } else {
            rememberMe.isSelected = true
        }
    }
    
    func underlined(){
        let borderBottom = CALayer()
        let borderBottom2 = CALayer()
        let borderWidth = CGFloat(2.0)
        
        borderBottom.borderColor = UIColor.gray.cgColor
        borderBottom.frame = CGRect(x: 0, y: userNameEdit.frame.height - 1.0, width: userNameEdit.frame.width , height: userNameEdit.frame.height - 1.0)
        borderBottom.borderWidth = borderWidth
        
        borderBottom2.borderColor = UIColor.gray.cgColor
        borderBottom2.frame = CGRect(x: 0, y: passwordEdit.frame.height - 1.0, width: passwordEdit.frame.width , height: passwordEdit.frame.height - 1.0)
        borderBottom2.borderWidth = borderWidth
        
        userNameEdit.layer.addSublayer(borderBottom)
        userNameEdit.layer.masksToBounds = true
        passwordEdit.layer.addSublayer(borderBottom2)
        passwordEdit.layer.masksToBounds = true
    }
    
    func standartLogin(){
        
        let userNameQuery = ref.child("users").queryOrdered(byChild: "name").queryEqual(toValue: userNameEdit.text)
        userNameQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let dict = child.value as! NSDictionary
                if (dict.value(forKey: "password") as? String == self.passwordEdit.text) {
                    print("zaebok")
                } else {
                    print("nexuya")
                }
                
                            }
           
        })
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
