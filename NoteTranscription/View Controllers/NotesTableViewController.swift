//
//  NotesTableViewController.swift
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/19/20.
//

import UIKit

class NotesTableViewController: UITableViewController {
    // MARK: - Properties
    let noteController = NoteController.shared
    let dateFormatter = DateFormatter()

    // MARK: - Functions
    @IBAction func unwindSegueToHome(segue:UIStoryboardSegue) {

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    // MARK: - Functions


    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteController.notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = noteController.notes[indexPath.row]

        if note.audioURL != nil {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as? AudioMemoTableViewCell else { return UITableViewCell() }

            cell.recordingURL = note.audioURL
            cell.titleLabel.text = note.title

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath)

            dateFormatter.dateFormat = "MM-dd-yyyy hh:mm"
            let dateString = dateFormatter.string(from: note.timestamp)

            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = dateString

            return cell
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SpeechToTextEditSegue" {
            let detailVC = segue.destination as? NotesDetailViewController

            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            detailVC?.note = noteController.notes[indexPath.row]
        }
    }
}
