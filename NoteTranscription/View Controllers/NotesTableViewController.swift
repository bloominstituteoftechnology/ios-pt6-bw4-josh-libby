//
//  NotesTableViewController.swift
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/19/20.
//

import UIKit

class NotesTableViewController: UITableViewController {

    var note: Notes?
    var notes: [Notes] = []
    var notesDelegate: NotesDelegate?

    // MARK: - Functions

    @IBAction func unwindSegueToHome(segue:UIStoryboardSegue) {

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]

        if note.audioURL != nil {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as? AudioMemoTableViewCell else { return UITableViewCell() }

            cell.recordingURL = note.audioURL
            cell.titleLabel.text = note.title

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
            let note = notes[indexPath.row]

            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = String(describing: note.timestamp)

            return cell
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SpeechToTextEditSegue" {
            let detailVC = segue.destination as? NotesDetailViewController

            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            detailVC?.note = notes[indexPath.row]
        }
    }
}
