//
//  ConfirmationQRViewController.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import UIKit
import CoreData

class ConfirmationQRViewController: UIViewController {

    @IBOutlet var QRImageView: UIImageView!
    
    var qrCodeImage: CIImage!
    
    var date: String?
    var lat: String?
    var long: String?
    var name: String?
    var publicKey: String?
    
    var myName: String?
    var myPublicKey: String?
    var myPrivateKey: String?

    @IBAction func doneAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let date = date, let lat = lat, let long = long else{
            return
        }
        
        let fetchRequest: NSFetchRequest<Owner> = Owner.fetchRequest()
        do {
            let owner = try PersistentService.context.fetch(fetchRequest)
            myName = owner[0].name
            myPublicKey = owner[0].publicKey
            myPrivateKey = owner[0].privateKey
            
//            print(myName!)
//            print(myPublicKey!)
        } catch{
            print("failed getting name and keys")
            return
        }
        
        //must create encrypted string here
        
        let rsa: RSAWrapper? = RSAWrapper()
        
        let success: Bool = (rsa?.generateKeyPair(keySize: 2048, privateTag: myPrivateKey!, publicTag: myPublicKey!))!
        
        if (!success) {
            print("Failed")
            return
        }
        
        let encryptString = "\(date),\(lat),\(long)\(publicKey!)"
        
        let encryption = rsa?.encryptBase64(text: encryptString)
        
        let decription = rsa?.decpryptBase64(encrpted: encryption!)
        
         //use the private key on this string
        
        //let result = encrypt(encryptString, myPrivateKey)
        
        let locationFinal = "\(lat),\(long)"
        
        setupQRCode(location: locationFinal, dateTime: date, encryptString: encryptString, myPublicKey: myPublicKey!,myName: myName!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupQRCode(location: String, dateTime: String, encryptString: String, myPublicKey: String, myName: String) {
        
        let dataString = "\(location),\(dateTime),\(encryptString),\(myPublicKey),\(myName)"
        
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
