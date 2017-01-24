//
//  settingsViewController.swift
//  together
//
//  Created by ASda Bogasd on 24.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit

class settingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutPressed(sender: AnyObject) {
        let defaults = UserDefaults.standard
        
        if let bundle = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: "com.together")
            defaults.synchronize()
        }
        self.performSegue(withIdentifier: "fromSettingsToLogin", sender: self)
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
