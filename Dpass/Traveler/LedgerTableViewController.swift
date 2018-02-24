//
//  LedgerTableViewController.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import UIKit
import CoreLocation

struct Event{
    var city: String?
    var country: String?
    var countryShortName: String?
    var dateTime: String?
}

class LedgerTableViewController: UITableViewController {

    let locationManager = CLLocationManager()
    var location: CLLocation?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    
    let tempLat = "40.1142726739917"
    let tempLong = "-88.2254133647812"
    
    var geoLocationArray: [Event] = []
    var cellTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        convertToGeoCode(lat: tempLat, long: tempLong)
        
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
        
        cell.detailTextLabel?.text = "DATETIME HERE"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellTitle = tableView.cellForRow(at: indexPath)?.textLabel?.text
        performSegue(withIdentifier: "showLedgerDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLedgerDetail", let destinationVC = segue.destination as? DetailViewController, let cellTitle = cellTitle {
                destinationVC.title = cellTitle
            }
    }
    
    func convertToGeoCode(lat: String?, long: String?){
        
        guard let lat = lat, let long = long else{
            return
        }
        
        let filledLat = Double(lat)
        let filledLong = Double(long)
        
        let convertedLat = CLLocationDegrees(filledLat!)
        let convertedLong = CLLocationDegrees(filledLong!)
        
        location = CLLocation(latitude: convertedLat, longitude: convertedLong)
        
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
        
        geoLocationArray.append(newGeolocation)
        //THIS MIGHT REALLY BREAK MIGHT NEED TO RELOCATE THIS
        tableView.reloadData()
    }
}
