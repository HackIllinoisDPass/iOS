//
//  QRCodeViewController.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import UIKit
import CoreLocation

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
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        let currLocation = "\(locValue.latitude),\(locValue.longitude)"
        
        setupQRCode(location: currLocation, publicKey: "12345")
    }
    
    func setupQRCode(location: String, publicKey: String) {
        let dataString = "\(currTime.toString(dateFormat: "dd-MMM-yyyy")),\(location),\(publicKey)"
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
