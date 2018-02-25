//
//  RegistrationViewController.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    let client = DPassRegisterClient()
    
    @IBOutlet var textField: UITextField!
    
    @IBAction func registerButton(_ sender: Any) {
        
        let textArray = textField.text?.split(separator: " ")
        
        if textArray?.count != 2{
            invalidNameEntry()
            textField.text = ""
            return
        }
        
        let preferences = UserDefaults.standard
        //making the request for the keys
        client.registerNewUser(from: .register){ result in
            switch result {
            case .success(let dPassRegistrationResult):
                guard let resultObject = dPassRegistrationResult else {
                    print("There was an error")
                    return
                }
                let ownerEntity = Owner(context: PersistentService.context)
                
                guard let f = textArray?[0], let l = textArray?[1] else{
                    print("There was an error for F and L")
                    return
                }
                
                let firstName = String(f)
                let lastName = String(l)
                
                ownerEntity.name = "\(firstName) \(lastName)"
                ownerEntity.publicKey = resultObject.publicKey
                ownerEntity.privateKey = resultObject.privateKey
                PersistentService.saveContext()
                
                print("success is \(dPassRegistrationResult)")
                
                //save core data object here
                
                preferences.set(true, forKey: "registeredUser")
                //self.showSuccessfulUserRegistrationAlert()
            case .failure(let error):
                print("the error \(error)")
                preferences.set(false, forKey: "registeredUser")
            }
        }
        
        //DO saving to coredata here. need to also retrieve wallet address to store into coredata
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func invalidNameEntry() {
        let alertPrompt = UIAlertController(title: "Name format invalid", message: "Please enter your name in the formatt {Firstname} {Lastname}", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        alertPrompt.addAction(action)
        
        present(alertPrompt, animated: true, completion: nil)
    }
}
