//
//  RemainderList+CoreDataProperties.swift
//  Sample
//
//  Created by Gopi Talari on 11/5/23.
//
//

import Foundation
import CoreData


extension RemainderList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RemainderList> {
        return NSFetchRequest<RemainderList>(entityName: "RemainderList")
    }

    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?

}

extension RemainderList : Identifiable {

}
