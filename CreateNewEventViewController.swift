//
//  CreateNeEventViewController.swift
//  
//
//  Created by ASda Bogasd on 21.01.17.
//
//

import UIKit

class CreateNewEventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var dataStartPicker: UIDatePicker!
    
    var pickerData: [String] = []
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        
        pickerData = ["celebrating", "helping"]
        
        
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
