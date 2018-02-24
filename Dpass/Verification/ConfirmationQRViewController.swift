//
//  ConfirmationQRViewController.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import UIKit

class ConfirmationQRViewController: UIViewController {

    @IBOutlet var QRImageView: UIImageView!
    
    var qrCodeImage: CIImage!
    
    var date: String?
    var lat: String?
    var long: String?
    var publicKey: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let date = date, let lat = lat, let long = long, let publicKey = publicKey{
            setupQRCode(date: date, lat: lat, long: long, publicKey: publicKey)
        }else{
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupQRCode(date: String, lat: String, long: String, publicKey: String) {
        let realDataString = "\(date),\(lat),\(long),\(publicKey)"
        let dataString = "\(date),\(publicKey)"
        
        //WILL NEED TO ENCRYPTWITH MY PRIVATE KEY HERE privateKey(dataString)
        
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
