//
//  DPassGetObjectResult.swift
//  Dpass
//
//  Created by Will Mock on 2/25/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//

import Foundation

struct DPassGetObjectResult: Decodable {
    let events: [DPassGetEventsResult]?
}
