//
//  DPassEventsClient.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import Foundation

class DPassEventsClient: APIClient {
    
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func getEvents(from DPassAPIType: DPassAPI, address: String, sender: String, completion: @escaping (Result<[DPassGetEventsResult]?, APIError>) -> Void) {
        
        var request = DPassAPIType.request
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let queryString = "?address=\(address)&sender=\(sender)"
        //print(request.url)
        let finalURL = (request.url?.absoluteString)! + queryString
        print(finalURL)
        let urlObject = URL(string: finalURL)
        request.url = urlObject
        
        print(request)
        
        fetchArray(with: request, decode: {json -> [DPassGetEventsResult]? in
            guard let dPassGetEventsResult = json as? [DPassGetEventsResult] else { return  nil }
            return dPassGetEventsResult
        }, completion: completion)
    }
}
