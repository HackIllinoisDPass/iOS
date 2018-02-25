//
//  VerificationScannerViewController.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class VerificationScannerViewController: UIViewController {

    @IBOutlet var topBar: UIView!
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var date: String?
    var lat: String?
    var long: String?
    var publicKey: String?
    var name: String?
    
    var geoLocationObject: Event?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: topBar)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    func launchApp(decodedMessage: String) {
        
        if presentedViewController != nil {
            return
        }
        
        if !decodedMessage.contains(","){
            invalidQRAlert()
        }
        
        let modifiedMessageArray = decodedMessage.split(separator: ",")
        
        if (modifiedMessageArray.count == 5) {
            date = String(modifiedMessageArray[0])
            lat = String(modifiedMessageArray[1])
            long = String(modifiedMessageArray[2])
            publicKey = String(modifiedMessageArray[3])
            name = String(modifiedMessageArray[4])
            
            let user = User(context: PersistentService.context)
            user.name = name
            user.publicKey = publicKey
            PersistentService.saveContext()
            
            convertToGeoCode(lat: lat, long: long, completionHandler: {
                guard let city = geoLocationObject?.city, let countryShortName = geoLocationObject?.countryShortName else{
                    return
                }
                
                let readableMessage = "Name: \(modifiedMessageArray[4])\nDate: \(modifiedMessageArray[0])\nLocation: \(city), \(countryShortName)\nPublicKey: \(modifiedMessageArray[3])\n"
                
                let alertPrompt = UIAlertController(title: "Confirm details", message: "\(readableMessage)", preferredStyle: .actionSheet)
                let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self.callCameraSegue()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                alertPrompt.addAction(confirmAction)
                alertPrompt.addAction(cancelAction)
                
                present(alertPrompt, animated: true, completion: nil)
            })
        }else{
            invalidQRAlert()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let DestViewController: ConfirmationQRViewController = segue.destination as! ConfirmationQRViewController
        
        DestViewController.date = date
        DestViewController.lat = lat
        DestViewController.long = long
        DestViewController.name = name
        DestViewController.publicKey = publicKey
    }
    
    func callCameraSegue() {
        performSegue(withIdentifier: "showVerification", sender: self)
    }
    
    func invalidQRAlert() {
        let alertPrompt = UIAlertController(title: "Could not scan QR code", message: "Invalid QR code", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            print("NOTHING TO DO")
        })
        
        alertPrompt.addAction(action)
        present(alertPrompt, animated: true, completion: nil)
    }
    
    func convertToGeoCode(lat: String?, long: String?, completionHandler: ()->(Void)){
        
        guard let lat = lat, let long = long else{
            return
        }
        
        let filledLat = Double(lat)
        let filledLong = Double(long)
        
        let convertedLat = CLLocationDegrees(filledLat!)
        let convertedLong = CLLocationDegrees(filledLong!)
        
        location = CLLocation(latitude: convertedLat, longitude: convertedLong)
        
        geocoder.reverseGeocodeLocation(location!, completionHandler: { (placemarks, error) in
            // always good to check if no error
            // also we have to unwrap the placemark because it's optional
            // I have done all in a single if but you check them separately
            if error == nil, let placemark = placemarks, !placemark.isEmpty {
                self.placemark = placemark.last
            }
            // a new function where you start to parse placemarks to get the information you need
            self.parsePlacemarks()
        })
        
        completionHandler()
    }
    
    func parsePlacemarks(){
        
        var newGeolocation = Event()
        
        if let _ = location {
            // unwrap the placemark
            if let placemark = placemark {
                // wow now you can get the city name. remember that apple refers to city name as locality not city
                // again we have to unwrap the locality remember optionalllls also some times there is no text so we check that it should not be empty
                if let city = placemark.locality, !city.isEmpty {
                    // here you have the city name
                    // assign city name to our iVar
                    newGeolocation.city = city
                }
                // the same story optionalllls also they are not empty
                if let country = placemark.country, !country.isEmpty {
                    newGeolocation.country = country
                }
                
                // get the country short name which is called isoCountryCode
                if let countryShortName = placemark.isoCountryCode, !countryShortName.isEmpty {
                    newGeolocation.countryShortName = countryShortName
                }
            }
        } else {
            // add some more check's if for some reason location manager is nil
            print("location manager is nil")
        }
        geoLocationObject = newGeolocation
    }
}


extension VerificationScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                launchApp(decodedMessage: metadataObj.stringValue!)
            }
        }
    }
}
