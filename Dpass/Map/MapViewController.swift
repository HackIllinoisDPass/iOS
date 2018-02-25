//
//  MapViewController.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    // Going to need to convert these strings into
    var lat: String?
    var long: String?
    
    let latArray = [37.331652997806785]
    let longArray = [-122.03072304117417]
    let tempLocationTitle = "TEMP NAME"
    let time = ["dd-MM-yyyy", "temp"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tempCoordinate = CLLocationCoordinate2DMake(latArray.last!, longArray.last!)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(tempCoordinate, span)
        
        mapView.setRegion(region, animated: true)
        
        for element in 0...latArray.count {
            let annotation = MKPointAnnotation()
            annotation.coordinate = tempCoordinate
            annotation.title = tempLocationTitle
            annotation.subtitle = time[element]
            self.mapView.addAnnotation(annotation)
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
