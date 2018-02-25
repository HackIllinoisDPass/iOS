//
//  Owner+CoreDataProperties.swift
//  Dpass
//
//  Created by Will Mock on 2/24/18.
//  Copyright © 2018 HackIllinoisDPass. All rights reserved.
//
//

import Foundation
import CoreData


extension Owner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Owner> {
        return NSFetchRequest<Owner>(entityName: "Owner")
    }

    @NSManaged public var publicKey: String?
    @NSManaged public var privateKey: String?
    @NSManaged public var name: String?

}
