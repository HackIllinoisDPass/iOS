//
//  MapViewController.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    // Going to need to convert these strings into
    var lat: String?
    var long: String?
    
    //let latArray = [37.331652997806785]
    //let longArray = [-122.03072304117417]
    var latArray: [Double] = []
    var longArray: [Double] = []
    //var locationTitle: [String] = []
    var time: [String] = []
    var pins = [Pin]()
    let client = DPassEventsClient()
    var coords = [CLLocationCoordinate2D]()
    var initialCoordinate = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        latArray = []
        longArray = []
        time = []
        
        var publicKey: String?
        let sender = "true"
        
        let fetchRequest: NSFetchRequest<Owner> = Owner.fetchRequest()
        do {
            let owner = try PersistentService.context.fetch(fetchRequest)
            publicKey = owner[0].publicKey
        } catch{
            print("failed getting name")
            return
        }
        
        guard let key = publicKey else{
            return
        }
        
        client.getEvents(from: .getevents, address: key, sender: sender){ result in
            switch result {
            case .success(let dPassGetAllResults):
                guard let resultObject = dPassGetAllResults else {
                    print("There was an error")
                    return
                }
                
                for event in resultObject.events!{
                    let locationArray = event.loc?.split(separator: ",")
                    let latString = String(locationArray![0])
                    let longString = String(locationArray![1])
                    self.latArray.append(Double(latString)!)
                    self.longArray.append(Double(longString)!)
                    self.time.append(event.time!)
                    //self.locationTitle.append(event)JEREMY FIX THIS
                    
                }
                if(self.latArray.count == 0){
                    self.initialCoordinate = CLLocationCoordinate2D(latitude: 40.1106, longitude: -88.2073)
                    self.mapView.setCenter(self.initialCoordinate, animated: true)
                } else {
                    self.initialCoordinate = CLLocationCoordinate2D(latitude: self.latArray.last!, longitude: self.longArray.last!)
                    let newCoord = CLLocationCoordinate2D(latitude: self.latArray.last!, longitude: self.longArray.last!)
                    self.mapView.setCenter(newCoord, animated: true)
                }

                
                self.mapView.delegate = self
                
                for element in 0..<self.latArray.count {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = self.initialCoordinate
                    annotation.title = ""//self.locationTitle[element]
                    annotation.subtitle = self.time[element]
                    self.mapView.addAnnotation(annotation)
//                    let tempPin = Pin(title: "", dateTime: self.time[element], coordinate: CLLocationCoordinate2D(latitude: self.latArray[element], longitude: self.longArray[element]))
//                    self.pins.append(tempPin)
                    self.coords.append(CLLocationCoordinate2D(latitude: self.latArray[element], longitude: self.longArray[element]))
                }
                if(self.coords.count == 0) {
                    self.coords.append(CLLocationCoordinate2D(latitude: 40.1106, longitude: -88.2073))
                }
                let testline = MKPolyline(coordinates: self.coords, count: self.coords.count)
                print(self.coords.count)
                self.mapView.add(testline)
                self.mapView.region = MKCoordinateRegion(center: self.coords[0], span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                
//                self.mapView.addAnnotations(self.pins)
            case .failure(let error):
                print("the error \(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MapViewController {
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? Pin else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}
