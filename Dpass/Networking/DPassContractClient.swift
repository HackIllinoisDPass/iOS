//
//  DPassContractClient.swift
//  Dpass
//
//  Created by Will Mock on 2/25/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import Foundation

class DPassContractClient: APIClient {
    
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func createContract(from DPassAPIType: DPassAPI, priv: String, signer: String, location: String, time: String, encData: String, completion: @escaping (Result<APISuccess, APIError>) -> Void) {
        
        var request = DPassAPIType.request
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let postString = "{\"sender\":\"\(priv)\",\"signer\":\"\(signer)\",\"location\":\"\(location)\",\"time\":\"\(time)\",\"encData\":\"\(encData)\"}"
        request.httpBody = postString.data(using: .utf8)
        
        fetch(with: request, completion: completion)
    }
}
