//
//  NoteTranscriptionViewController.swift
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/19/20.
//

import UIKit
import Speech
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class NoteTranscriptionViewController: UIViewController {
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var noteImage: UIImageView!
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var chooseImageButton: UIButton!
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer()
    let noteController = NoteController.shared
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioRecorder: AVAudioRecorder?
    var notes: Notes?
    var noteDelegate: NotesDelegate?

    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else {
                scaledImage = nil
                return
            }

            var scaledSize = noteImage.bounds.size
            let scale = noteImage.contentScaleFactor

            scaledSize.width *= scale
            scaledSize.height *= scale

            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else {
                scaledImage = nil
                return
            }

            scaledImage = CIImage(image: scaledUIImage)
        }
    }

    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func imageButtonTapped(_ sender: UIButton) {
        showImagePickerControllerActionSheet()
        chooseImageButton.isHidden = true
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let title = noteTitle.text,
              let image = noteImage.image?.pngData(),
              !title.isEmpty,
              !image.isEmpty else { return }

        noteController.createNote(with: title, bodyText: noteText.text, timestamp: Date(), image: image)

        performSegue(withIdentifier: "unwindSegueToHome", sender: self)

        resetForm()
    }

    func resetForm() {
        noteTitle.text = nil
        noteText.text = nil
        noteImage.image = nil
        chooseImageButton.isHidden = false

    }

    private func showImagePickerControllerActionSheet() {
        let alert = UIAlertController()

        let photoLibraryAction = UIAlertAction(title: "Choose from Library", style: .default) { (action) in
            self.presentImagePickerController(sourceType: .photoLibrary)
        }

        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.presentImagePickerController(sourceType: .camera)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true)

    }

    private func presentImagePickerController(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("The photo library is not available.")
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self

        present(imagePicker, animated: true, completion: nil)
    }

    private func updateImage() {
        if let scaledImage = scaledImage {
            noteImage.image = image(byFiltering: scaledImage)
        } else {
            noteImage.image = nil
        }
    }

    private func image(byFiltering inputImage: CIImage) -> UIImage? {
        guard let currentCGImage = inputImage.cgImage else { return nil }
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(currentCIImage, forKey: "inputImage")

        filter?.setValue(1.0, forKey: "inputIntensity")
        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()

        let cgimg = context.createCGImage(outputImage, from: outputImage.extent)!
        let processedImage = UIImage(cgImage: cgimg)

        return processedImage
    }

    func saveImage() {
        guard let originalImage = originalImage?.flattened,
        let ciImage = CIImage(image: originalImage)
    else { return }

    guard let processedImage = image(byFiltering: ciImage) else { return }

    PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAsset(from: processedImage)
    }) { (success, error) in
        if let error = error {
            print("Error saving photo: \(error)")
            return
        }

        DispatchQueue.main.async {
            self.presentSuccessfulSaveAlert()
        }
    }
}

    private func presentSuccessfulSaveAlert() {
    let alert = UIAlertController(title: "Photo Saved!", message: "The photo has been saved to your Photo Library!", preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

    present(alert, animated: true, completion: nil)
}

    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            if status == .authorized {
                self.recordAndTranscribe()
            }
        }
    }

    private func recordAndTranscribe() {
        request = SFSpeechAudioBufferRecognitionRequest()

        let recordingURL = createNewRecordingURL()
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            NSLog("Error processing speech: \(error)")
        }

        guard
            let request = request,
            let speechRecognizer = speechRecognizer,
            speechRecognizer.isAvailable else { return }

        recognitionTask = speechRecognizer.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let transcriptText = result.bestTranscription.formattedString
                self.noteText.text = transcriptText
                self.notes?.audioURL = recordingURL

            } else if let error = error {
                NSLog("Error recognising speech: \(error)")
                print("\(error.localizedDescription)")
            }
        })
    }

    private func stopSpeechRecognition() {

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        request?.endAudio()
        request = nil

        recognitionTask?.cancel()
        recognitionTask = nil
    }

    private func prepareAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.record, options: [.defaultToSpeaker])
            try audioSession.setActive(true, options: [])
        } catch {
            NSLog("An error has occurred while setting the AVAudioSession: \(error)")
        }
    }

    private func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")

        return file
    }
}


extension NoteTranscriptionViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
}

extension NoteTranscriptionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[.editedImage] as? UIImage {
            originalImage = image
        } else if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
