//
//  ImageHelper.swift
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/22/20.
//

import Foundation
import class UIKit.UIImage
import CoreData

extension UIImage {
    var toData: Data? {
        return pngData()
    }
}

class ImageHelper {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    private func saveContext() {
        try! container.viewContext.save()
    }

    func makeInternallyStoredImage(_ bitmap: UIImage) -> NotesInternalStorage {
        let image = insert(NotesInternalStorage.self, into: container.viewContext)
        image.img = bitmap.toData as NSData?
        saveContext()
        return image
    }

    func internallyStoredImage(by id: NSManagedObjectID) -> NotesInternalStorage {
        return container.viewContext.object(with: id) as! NotesInternalStorage
    }

    private func insert<T>(_ type: T.Type, into context: NSManagedObjectContext) -> T {
        return NSEntityDescription.insertNewObject(forEntityName: String(describing: T.self), into: context) as! T
    }
}
