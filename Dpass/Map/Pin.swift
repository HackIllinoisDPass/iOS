//
//  Pin.swift
//  Dpass
//
//  Created by Jeremy Gonzalez on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import Foundation
import MapKit

class Pin: NSObject, MKAnnotation {
    let title: String?
    let dateTime: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, dateTime: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.dateTime = dateTime
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String?{
        return dateTime
    }
}

