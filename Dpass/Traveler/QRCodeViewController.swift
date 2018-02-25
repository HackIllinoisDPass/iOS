//
//  QRCodeViewController.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class QRCodeViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet var QRImageView: UIImageView!
    
    var qrCodeImage: CIImage!
    
    let currTime = Date()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        locationManager.stopUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let currLocation = "\(locValue.latitude),\(locValue.longitude)"
        setupQRCode(location: currLocation)
    }
    
    func setupQRCode(location: String) {
        var name: String
        var publicKey: String
        
        let fetchRequest: NSFetchRequest<Owner> = Owner.fetchRequest()
        do {
            let owner = try PersistentService.context.fetch(fetchRequest)
            
            name = owner[0].name!
            publicKey = owner[0].publicKey!
            
            print(name)
            print(publicKey)
        } catch{
            print("failed getting name")
            return
        }
        
        let dataString = "\(currTime.toString(dateFormat: "dd-MMM-yyyy")),\(location),\(publicKey),\(name)"
        print(dataString)
        
        let data = dataString.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        qrCodeImage = filter?.outputImage
        
        let scaleX = QRImageView.frame.size.width / qrCodeImage.extent.size.width
        let scaleY = QRImageView.frame.size.height / qrCodeImage.extent.size.height
        
        let transformedImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        QRImageView.image = UIImage(ciImage: transformedImage)
    }
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
