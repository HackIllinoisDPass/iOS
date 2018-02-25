//
//  DetailViewController.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet var titleBarTitle: UINavigationItem!
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var leftLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var city: String?
    var country: String?
    var countryShortName: String?
    var dateTime: String?
    var sender: String?
    var signer: String?
    var data: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<Owner> = Owner.fetchRequest()
        do {
            let owner = try PersistentService.context.fetch(fetchRequest)
            let myPublicKey = owner[0].publicKey
            let name = owner[0].name
            
            if (myPublicKey == sender){
                leftLabel.text = name
            }
            
        } catch{
            print("failed getting name and keys")
            return
        }
        
        let fetchUsers: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try PersistentService.context.fetch(fetchUsers)
            
            for user in users{
                if user.publicKey == signer {
                    rightLabel.text = user.name
                }else{
                    rightLabel.text = signer    
                }
            }
        } catch{
            print("failed getting name and keys")
            return
        }
        //need to set up and write all of this data to these views
        
        // Do any additional setup after loading the view.
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
