//
//  ShoppingList+CoreDataProperties.swift
//  Shopper
//
//  Created by student on 3/22/16.
//  Copyright © 2016 Aquino. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ShoppingList {

    @NSManaged var date: String
    @NSManaged var name: String
    @NSManaged var store: String
    @NSManaged var items: NSSet?

}
