//
//  DPassRegistrationResult.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import Foundation

struct DPassRegistrationResult: Decodable {
    let publicKey: String?
    let privateKey: String?
}
