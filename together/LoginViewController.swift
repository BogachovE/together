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
    @IBOutlet weak var emailEdit: UITextField!
    @IBOutlet weak var rememberMe: UIButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var userRepositories: UserRepositories!
    var myAccessToken: String!
    var user: User!
    var pass: String!
    var userId : AnyObject? {
        get {
            return UserDefaults.standard.object(forKey: "userId") as AnyObject?
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userId")
            UserDefaults.standard.synchronize()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: "userId") as Int!
        if (id != nil && id != 0){self.performSegue(withIdentifier: "fromLoginToMain", sender: self)}

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
    
    @IBAction func forgetPasswordPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Forget my password", message: "Plese enter your email", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addTextField { (emailTextView) in
            
        }
        self.present(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                let textField = alert.textFields![0]
                self.findPassword(email: textField.text)
                FIRAuth.auth()?.sendPasswordReset(withEmail: textField.text!) { (error) in
                    if (error == nil) {self.makeToast(text: "We send you a mail")}
                }
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))
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
        borderBottom.frame = CGRect(x: 0, y: emailEdit.frame.height - 1.0, width: emailEdit.frame.width , height: emailEdit.frame.height - 1.0)
        borderBottom.borderWidth = borderWidth
        
        borderBottom2.borderColor = UIColor.gray.cgColor
        borderBottom2.frame = CGRect(x: 0, y: passwordEdit.frame.height - 1.0, width: passwordEdit.frame.width , height: passwordEdit.frame.height - 1.0)
        borderBottom2.borderWidth = borderWidth
        
        emailEdit.layer.addSublayer(borderBottom)
        emailEdit.layer.masksToBounds = true
        passwordEdit.layer.addSublayer(borderBottom2)
        passwordEdit.layer.masksToBounds = true
    }
    
    func standartLogin(){
        FIRAuth.auth()?.signIn(withEmail: emailEdit.text!, password: passwordEdit.text!) { (usser, error) in
            // ...
            if (usser != nil) {
                print(usser?.email! as Any)
                let userNameQuery = self.ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: self.emailEdit.text)
                userNameQuery.observeSingleEvent(of: .value, with: { (snapshot) in
                    if(snapshot.hasChildren()) {                            //If t=we have user with this login
                        for item in snapshot.children {
                            let child = item as! FIRDataSnapshot
                            let dict = child.value as! NSDictionary
                            if (self.rememberMe.isSelected) {
                                let id = dict.value(forKey: "id")
                                self.userId = id as AnyObject?
                            }
                            self.performSegue(withIdentifier: "fromLoginToMain", sender: self)
                        }
                    }
                })
                
                
            }
            if (error != nil) {print(error!)
                                self.makeToast(text: "Incorect email")}
            
        }
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
                self.performSegue(withIdentifier: "fromLoginToMain", sender: self)

                
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
                if (self.rememberMe.isSelected) {
                    let id = Int((result as! NSObject).value(forKey: "id") as! String)!
                    self.userId = id as AnyObject?
                }
                self.user.name = (result as! NSObject).value(forKey: "name")! as! String
                self.user.id = Int((result as! NSObject).value(forKey: "id") as! String)!
                self.userRepositories.addnewUser(user: self.user, ref: self.ref, storageRef: self.storageRef)
                
                
                
            }
        })
    }
    
    
    
    func findPassword(email: String!)  {
            let emailQuery = ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email)
        emailQuery.observeSingleEvent(of: .value, with: {(snapshot) in
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let dict = child.value as! NSDictionary
                self.pass = dict.value(forKey: "password") as! String
                print(dict.value(forKey: "password")!)
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
