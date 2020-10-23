//
//  CoreDataStack.swift
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/19/20.
//

import Foundation
import CoreData

class CoreDataStack {
    // Static makes it a class property
    static let shared = CoreDataStack()

    lazy var container: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "Note")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return container
    }()

    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
