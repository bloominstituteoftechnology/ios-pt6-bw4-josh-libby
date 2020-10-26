//
//  CoreDataStack.swift
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/25/20.
//
import CoreData

@objcMembers
@objc(BW4CoreDataStack)
class CoreDataStack: NSObject {

    @objc(sharedStack)
    static let shared = CoreDataStack()

    lazy var container: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "NoteTranscription")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return container
    }()

    @objc(mainContext)
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }

    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        var error: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
    }
}
