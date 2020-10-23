//
//  NotesDetailViewController.swift
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/19/20.
//

import UIKit

class NotesDetailViewController: UIViewController {
    // MARK: - Properties
    var note: Notes?

    // MARK: - IBOutlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var bodyTextView: UITextView!

    // MARK: - View Live Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }

    // MARK: - Functions
    func updateViews() {
        guard let note = note, let image = UIImage(data: note.img) else { return }

        imageView.image = image
        titleTextField.text = note.title
        bodyTextView.text = note.bodyText

    }
}
