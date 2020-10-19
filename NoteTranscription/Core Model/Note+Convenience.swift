//
//  Note+Convenience.swift
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/19/20.
//

import Foundation
import CoreData


extension Note {
    @discardableResult convenience init(title: String?,
                                    bodyText: String?,
                                    timestamp: Date? = Date(),
                                    context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
    self.init(context: context)
    self.title = title
    self.bodyText = bodyText
    self.timestamp = timestamp
    }
}
