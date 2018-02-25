//
//  LedgerTableViewController.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

struct Event{
    var city: String?
    var country: String?
    var countryShortName: String?
    var dateTime: String?
    var sender: String?
    var signer: String?
    var data: String?
}

class LedgerTableViewController: UITableViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var location: CLLocation?
    
    var dateTime: String?
    var sender: String?
    var signer: String?
    var data: String?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    
    var geoLocationArray: [Event] = []
    var cellTitle: String?
    var cellNumber = 0
    
    let client = DPassEventsClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        var name: String?
        var publicKey: String?
        let sender = "true"
        
        let fetchRequest: NSFetchRequest<Owner> = Owner.fetchRequest()
        do {
            let owner = try PersistentService.context.fetch(fetchRequest)
            
            name = owner[0].name
            publicKey = owner[0].publicKey
            print(publicKey)
        } catch{
            print("failed getting name")
            return
        }
        
        guard let key = publicKey else{
            print("TEST")
            return
        }
        
        client.getEvents(from: .getevents, address: key, sender: sender){ result in
            switch result {
            case .success(let dPassGetAllResults):
                guard let resultObject = dPassGetAllResults else {
                    print("There was an error")
                    return
                }
                print("success is \(resultObject)")
                
                for event in resultObject.events!{
                    let locationArray = event.loc?.split(separator: ",")
                    let lat = String(locationArray![0])
                    let long = String(locationArray![1])
                    
                    self.convertToGeoCode(lat: lat, long: long, time: event.time, sender: event._sender, signer: event._signer, data: event.encData)
                }
            case .failure(let error):
                print("the error \(error)")
            }
        }
        
        //Will need to call this on all returned values
        //convertToGeoCode(lat: tempLat, long: tempLong)
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return geoLocationArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ledgerCell")!
        
        guard let countrySN = geoLocationArray[indexPath.row].countryShortName, let city = geoLocationArray[indexPath.row].city else{/*, let datetime = geoLocationArray[indexPath.row].dateTime*/
            cell.textLabel?.text = "error"
            return cell
        }
        
        cell.textLabel?.text = "\(city), \(countrySN)"
        
        cell.detailTextLabel?.text = geoLocationArray[indexPath.row].dateTime
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellTitle = tableView.cellForRow(at: indexPath)?.textLabel?.text
        cellNumber = indexPath.row
        performSegue(withIdentifier: "showLedgerDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLedgerDetail", let destinationVC = segue.destination as? DetailViewController, let cellTitle = cellTitle {
                destinationVC.title = cellTitle
                destinationVC.city = geoLocationArray[cellNumber].city
                destinationVC.country = geoLocationArray[cellNumber].country
                destinationVC.countryShortName = geoLocationArray[cellNumber].countryShortName
                destinationVC.data = geoLocationArray[cellNumber].data
                destinationVC.dateTime = geoLocationArray[cellNumber].dateTime
                destinationVC.sender = geoLocationArray[cellNumber].sender
                destinationVC.signer = geoLocationArray[cellNumber].signer
            
        }
    }
    
    func convertToGeoCode(lat: String?, long: String?, time: String?, sender: String?, signer: String?, data: String?){
        
        guard let lat = lat, let long = long else{
            return
        }
        
        let filledLat = Double(lat)
        let filledLong = Double(long)
        
        let convertedLat = CLLocationDegrees(filledLat!)
        let convertedLong = CLLocationDegrees(filledLong!)
        
        location = CLLocation(latitude: convertedLat, longitude: convertedLong)
        
        self.dateTime = time
        self.sender = sender
        self.signer = signer
        self.data = data
        
        geocoder.reverseGeocodeLocation(location!, completionHandler: { (placemarks, error) in
            
            if error == nil, let placemark = placemarks, !placemark.isEmpty {
                self.placemark = placemark.last
            }
            
            self.parsePlacemarks()
        })
    }
    
    func parsePlacemarks(){
        
        var newGeolocation = Event()
        
        if let _ = location {
            // unwrap the placemark
            if let placemark = placemark {
                
                if let city = placemark.locality, !city.isEmpty {
                    newGeolocation.city = city
                }
                
                if let country = placemark.country, !country.isEmpty {
                    newGeolocation.country = country
                }
                
                if let countryShortName = placemark.isoCountryCode, !countryShortName.isEmpty {
                    newGeolocation.countryShortName = countryShortName
                }
            }
        } else {
        // add some more check's if for some reason location manager is nil
            print("location manager is nil")
        }
        
        newGeolocation.data = data
        newGeolocation.dateTime = dateTime
        newGeolocation.sender = sender
        newGeolocation.signer = signer
        
        geoLocationArray.append(newGeolocation)
        //THIS MIGHT REALLY BREAK MIGHT NEED TO RELOCATE THIS
        tableView.reloadData()
    }
}
