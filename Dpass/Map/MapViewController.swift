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
    let tempLocationTitle = "TEMP NAME"
    let time = ["dd-MM-yyyy", "temp"]
    
    let client = DPassEventsClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        latArray = []
        longArray = []
        
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
                }
                
                let tempCoordinate = CLLocationCoordinate2DMake(self.latArray.last!, self.longArray.last!)
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegionMake(tempCoordinate, span)
                
                self.mapView.setRegion(region, animated: true)
                
                for element in 0...self.latArray.count {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = tempCoordinate
                    annotation.title = self.tempLocationTitle
                    annotation.subtitle = self.time[element]
                    self.mapView.addAnnotation(annotation)
                }
            case .failure(let error):
                print("the error \(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Called when the annotation was added
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            pinView?.isDraggable = false
            pinView?.pinTintColor = .red
            
            let rightButton: AnyObject! = UIButton(type: UIButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = rightButton as? UIView
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print(#function)
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "toTheMoon", sender: self)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.ending {
            let droppedAt = view.annotation?.coordinate
            print(droppedAt ?? "coordicate is nil")
        }
    }

}
