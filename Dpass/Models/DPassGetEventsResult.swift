//
//  DPassGetEventsResult.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import Foundation

struct DPassGetEventsResult: Decodable {
    let loc: String?
    let time: String?
    let encData: String?
    let _sender: String?
    let _signer: String?
    let type: String?
}
