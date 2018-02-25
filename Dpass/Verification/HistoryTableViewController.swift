//
//  HistoryTableViewController.swift
//  Dpass
//
//  Created by Will Mock on 2/25/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    var date: String?
    var lat: String?
    var long: String?
    var name: String?
    var publicKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let sender = "false"
        
        guard let key = publicKey else{
            return
        }
        let client = DPassEventsClient()
        
        client.getEvents(from: .getevents, address: key, sender: sender){ result in
            switch result {
            case .success(let dPassGetAllResults):
                guard let resultObject = dPassGetAllResults else {
                    print("There was an error")
                    return
                }
                
                for event in resultObject.events!{
                    let locationArray = event.loc?.split(separator: ",")
                    let lat = String(locationArray![0])
                    let long = String(locationArray![1])
                    
                    //this is where I will save the stuff into an array
                }
            case .failure(let error):
                print("the error \(error)")
            }
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let DestViewController: ConfirmationQRViewController = segue.destination as! ConfirmationQRViewController
        
        DestViewController.date = date
        DestViewController.lat = lat
        DestViewController.long = long
        DestViewController.name = name
        DestViewController.publicKey = publicKey
    }
 

}
