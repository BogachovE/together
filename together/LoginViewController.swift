//
//  LoginViewController.swift
//  together
//
//  Created by ASda Bogasd on 15.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import FBSDKCoreKit

class LoginViewController: UIViewController  {

    @IBOutlet weak var passwordEdit: UITextField!
    @IBOutlet weak var userNameEdit: UITextField!
    @IBOutlet weak var rememberMe: UIButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var userRepositories: UserRepositories!
    var myAccessToken: String!
    var user: User!
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
        ref = FIRDatabase.database().reference()
        underlined()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        userRepositories = UserRepositories()
        // Do any additional setup after loading the view.
    }
   
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fbPressed(_ sender: Any) {
        facebookLogin(fromViewController: self)
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
            if(snapshot.hasChildren()) {                            //If t=we have user with this login
                for item in snapshot.children {
                    let child = item as! FIRDataSnapshot
                    let dict = child.value as! NSDictionary
                    if (dict.value(forKey: "password") as? String == self.passwordEdit.text) {
                        if (self.rememberMe.isSelected) {
                            let id = dict.value(forKey: "id")
                            self.userId = id as AnyObject?
                        }
                    self.performSegue(withIdentifier: "toMain", sender: self)
                    } else {
                        self.makeToast(text: "Username or password incorect")
                        }
                }
            } else {
                    self.makeToast(text: "Username or password incorect")
                }
        })
        
    }
  
    func facebookLogin(fromViewController:UIViewController)  {
        let loginManager = LoginManager()
        loginManager.loginBehavior = LoginBehavior.native;
        
        loginManager.logIn([.publicProfile, .email], viewController: fromViewController) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in \(grantedPermissions) \(declinedPermissions) \(accessToken)")
                self.returnUserData()
                self.user = User()
                
            }
        }
        
    }
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                self.user.name = (result as! NSObject).value(forKey: "name")! as! String
                self.user.id = Int((result as! NSObject).value(forKey: "id") as! String)!
                self.userRepositories.addnewUser(user: self.user, ref: self.ref, storageRef: self.storageRef)
                
     
    
            }
        })
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
