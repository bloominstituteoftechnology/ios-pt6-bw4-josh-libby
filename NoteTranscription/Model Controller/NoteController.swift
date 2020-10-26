//
//  NoteController.swift
//  NoteTranscription
//
//  Created by Elizabeth Thomas on 10/23/20.
//

import Foundation
import UIKit

class NoteController {

    static let shared = NoteController()

    var notes: [Notes] = []

    func createNote(with title: String, bodyText: String, timestamp: Date, image: Data) {

        let note = Notes(title: title, bodyText: bodyText, timestamp: timestamp, img: image)
        notes.append(note)

        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            print("Error saving Note")
        }
    }

    func createAudioNote(with title: String, audioURL: URL) {

        let note = Notes(title: title, audioURL: audioURL)
        notes.append(note)

        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            print("Error saving Note")
        }
    }
}
