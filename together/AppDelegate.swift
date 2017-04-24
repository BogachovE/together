//
//  AppDelegate.swift
//  together
//
//  Created by ASda Bogasd on 12.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FBSDKCoreKit
import OneSignal
import GoogleSignIn
import GooglePlaces
import GoogleMaps




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        GMSPlacesClient.provideAPIKey("AIzaSyDqLRk1pMJ7q8Ch0L_qvRKqU8CPi2b298A")
        GMSServices.provideAPIKey("AIzaSyDqLRk1pMJ7q8Ch0L_qvRKqU8CPi2b298A")
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "aab72c04-c005-49da-a064-d4e93e7fed76")
        OneSignal.initWithLaunchOptions(launchOptions, appId: "aab72c04-c005-49da-a064-d4e93e7fed76", handleNotificationReceived: { (notification) in
            print("Received Notification - \(notification?.payload.notificationID)")
        }, handleNotificationAction: { (result) in
            let payload: OSNotificationPayload? = result?.notification.payload
            
            var fullMessage: String? = payload?.body
            if payload?.additionalData != nil {
                var additionalData: [AnyHashable: Any]? = payload?.additionalData
                if additionalData!["actionSelected"] != nil {
                    fullMessage = fullMessage! + "\nPressed ButtonId:\(additionalData!["actionSelected"])"
                }
            }
            
            print(fullMessage)
        }, settings: [kOSSettingsKeyAutoPrompt : true])
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let faceReturn = FBSDKApplicationDelegate.sharedInstance().application(app,open: url,sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        let googleReturn = GIDSignIn.sharedInstance().handle(url,
                                                                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return googleReturn
    }
    
   
    
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("GOOGLE ERROR")
            return
        }
        
        OneSignal.idsAvailable({(_ userNotifId, _ pushToken) in
            let userM = User()
            print("UserId:\(userNotifId)")
            if pushToken != nil {
                print("pushToken:\(pushToken)")
            }
            let ref = FIRDatabase.database().reference()
            
            ref.child("users").observeSingleEvent(of: .value, with: {(snapshot) in
                userM.name = user.profile.name
                let googleUserQuery = ref.child("users").queryOrdered(byChild: "name").queryEqual(toValue: userM.name)
                googleUserQuery.observeSingleEvent(of: .value, with: { (snapshot) in
                    if (snapshot.exists()){
                        for i in snapshot.children{
                            UserDefaults.standard.set(((i as! FIRDataSnapshot).value as! NSDictionary).value(forKey: "id") as! Int, forKey: "userId")
                            UserDefaults.standard.synchronize()
                        }
                        
                    } else {
                        userM.email = user.profile.email
                        userM.id = UInt64((snapshot.childSnapshot(forPath: "count").value) as! Int + 1)
                        userM.notificationId = userNotifId!
                        UserDefaults.standard.set(userM.id, forKey: "userId")
                        UserDefaults.standard.synchronize()
                        
                        let storage = FIRStorage.storage()
                        let storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
                        let userRepositories = UserRepositories()
                        userRepositories.addnewUser(user: userM, ref: ref, storageRef: storageRef)
                    }
                    
                    let myStoryBoard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
                    
                    let protectedPage = myStoryBoard.instantiateViewController(withIdentifier: "feedViewController") as! FeedViewController
                    
                    //let protectedPageNav = UINavigationController(rootViewController: protectedPage)
                    let protectedPageNav = UINavigationController(rootViewController: protectedPage)
                    
                    self.window?.rootViewController = protectedPage
                    
                })
            })
            
            guard let authentication = user.authentication else { return }
            let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                              accessToken: authentication.accessToken)
            // ...
            
            
        })
    }
    
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    
    
    
}

