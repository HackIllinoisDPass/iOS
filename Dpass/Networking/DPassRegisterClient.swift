//
//  DPassRegisterClient.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import Foundation

class DPassRegisterClient: APIClient {
    
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func registerNewUser(from DPassAPIType: DPassAPI, completion: @escaping (Result<DPassRegistrationResult?, APIError>) -> Void) {
        
        var request = DPassAPIType.request
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        fetch(with: request, decode: {json -> DPassRegistrationResult? in
            guard let dPassRegistrationResult = json as? DPassRegistrationResult else { return  nil }
            return dPassRegistrationResult
        }, completion: completion)
    }
}
