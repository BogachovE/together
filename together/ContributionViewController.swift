//
//  ContributionViewController.swift
//  together
//
//  Created by ASda Bogasd on 23.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import UIKit

class ContributionViewController: UIViewController, PayPalPaymentDelegate{
    @IBOutlet var payButtonLabel: UILabel!
    @IBOutlet var editSum: UITextField!
    @IBOutlet var agreeButton: UIButton!
    
    var event : Event!
    var myId: Int!
    
    var payPalConfig = PayPalConfiguration()
    
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var acceptCreditCards: Bool = true {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Load userDefaults
        let defaults = UserDefaults.standard
        myId = defaults.integer(forKey: "userId")
        
        
        payPalConfig.acceptCreditCards = acceptCreditCards
        payPalConfig.merchantName = "Siva Ganesh Inc."
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.sivaganesh.com/privacy.html") as URL!
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.sivaganesh.com/useragreement.html") as URL!
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .both;
        
        //PayPalMobile.preconnect(withEnvironment: environment)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sumEditEnd(_ sender: Any) {
        editSum.text = editSum.text!+".00"
        
    }
    @IBAction func editSumOut(_ sender: Any) {
        editSum.text = editSum.text!+".00"
       

    }
    @IBAction func editSumChange(_ sender: UITextField) {
         payButtonLabel.text = "Pay " + editSum.text! + " $"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController!) {
        print("PayPal Payment Cancelled")
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController!, didComplete completedPayment: PayPalPayment!) {
        print("PayPal Payment Success !")
        let contributeSum = editSum.text
        let userRepositories = UserRepositories()
        userRepositories.loadUser(userId: myId, withh: { (user) in
            let notificationRepositories = NotificationRepositories()
            notificationRepositories.contributeNotification(event: self.event, user: user, sum: Int(contributeSum!)!)
        })
                paymentViewController?.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "cancel") {
            let svc = segue.destination as! EventViewController
            
            svc.eventId = event.id
            
        }
    }

    
    @IBAction func agreementButtonPressed(_ sender: Any) {
            if (agreeButton.isSelected == true){
                agreeButton.isSelected = false
            }else{
                agreeButton.isSelected = true
            }
    }
   
    @IBAction func payButtonPressed(_ sender: Any) {
        let contributeSum = editSum.text
        // Process Payment once the pay button is clicked.
        if (agreeButton.isSelected == true && contributeSum != ""){
            let item1 = PayPalItem(name: "Contribute Item", withQuantity: 1, withPrice: NSDecimalNumber(string: contributeSum), withCurrency: "USD", withSku: "Hip-0037")
            
            let items = [item1]
            let subtotal = PayPalItem.totalPrice(forItems: items)
            
            // Optional: include payment details
            let shipping = NSDecimalNumber(string: "0.00")
            let tax = NSDecimalNumber(string: "0.00")
            let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
            
            let total = subtotal.adding(shipping).adding(tax)
            
            let shortDescription = "Contribute " + event.title
            let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: shortDescription, intent: .sale)
            
            payment.items = items
            payment.paymentDetails = paymentDetails
            
            if (payment.processable) {
                
                let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
                present(paymentViewController!, animated: true, completion: nil)
            }
            else {
                
                print("Payment not processalbe:)")
            }
        } else {
            makeToast(text: "plese agree with our agreement")
        }
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
