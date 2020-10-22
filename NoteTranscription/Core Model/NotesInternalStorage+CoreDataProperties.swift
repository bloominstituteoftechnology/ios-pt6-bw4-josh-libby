//
//  NotesInternalStorage+CoreDataProperties.swift
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/22/20.
//

import Foundation
import CoreData

extension NotesInternalStorage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotesInternalStorage> {
        return NSFetchRequest<NotesInternalStorage>(entityName: "Notes")
    }

    @NSManaged public var img: NSData?

}
