//
//  NotesTableViewController.swift
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/19/20.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    // MARK: - Properties
    let noteController = NoteController.shared
    let dateFormatter = DateFormatter()

    var fetchResultsController: NSFetchedResultsController<Note> {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        let moc = CoreDataStack.shared.mainContext
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        return fetchResultsController
    }

    // MARK: - Functions
    @IBAction func unwindSegueToHome(segue:UIStoryboardSegue) {
        
    }

    @IBAction func unwindSegueToMain(segue:UIStoryboardSegue) {

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
    }

    // MARK: - Functions


    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteController.notes.count // <-- This works, but needs to be this --> fetchResultsController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = noteController.notes[indexPath.row] // <-- This works, but needs to be this --> fetchResultsController.object(at: indexPath)

        if note.audioURL != nil {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as? AudioMemoTableViewCell else { return UITableViewCell() }

            cell.recordingURL = note.audioURL // <-- This works, but needs to be this --> URL(string: note.audioURL!)
            cell.titleLabel.text = note.title

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath)

            dateFormatter.dateFormat = "MM-dd-yyyy hh:mm"
            let dateString = dateFormatter.string(from: note.timestamp) // <-- This works, but needs to be this --> dateFormatter.string(from: note.timestamp!)

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

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                  let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}

