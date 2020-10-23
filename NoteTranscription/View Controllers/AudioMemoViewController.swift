//
//  AudioMemoViewController.swift
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/19/20.
//

import UIKit
import AVFoundation

protocol AudioAddedDelegate {
    func reloadData()
}

class AudioMemoViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet var playButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var audioVisualizer: AudioVisualizer!

    // MARK: - Properties
    weak var timer: Timer?
    var recordingURL: URL?
    var audioRecorder: AVAudioRecorder?
    var delegate: AudioAddedDelegate?

    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }

            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
            updateViews()
        }
    }

    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()

    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }

    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }

    // MARK: - Lifecycle Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize, weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize, weight: .regular)
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - IBActions
    @IBAction func togglePlayback(_ sender: Any) {
        if isPlaying{
            pause()
        } else {
            play()
        }
    }

    @IBAction func toggleRecording(_ sender: Any) {
        if isRecording {
                stopRecording()
            } else {
                requestPermissionOrStartRecording()
        }
    }

    @IBAction func updateCurrentTime(_ sender: UISlider) {
        if isPlaying {
            pause()
        }

        audioPlayer?.currentTime = TimeInterval(sender.value)
        updateViews()
    }

    @IBAction func saveRecording(_ sender: Any) {
        // save recording here
        self.delegate?.reloadData()

        navigationController?.popViewController(animated: true)
    }

    // MARK: - Functions
    func updateViews() {
        playButton.isEnabled = !isRecording
        recordButton.isEnabled = !isPlaying
        timeSlider.isEnabled = !isRecording

        playButton.isSelected = isPlaying
        recordButton.isSelected = isRecording

        if !isRecording {
            let elapsedTime = audioPlayer?.currentTime ?? 0
            let duration = audioPlayer?.duration ?? 0
            let timeRemaining = duration.rounded() - elapsedTime

            timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)

            timeSlider.minimumValue = 0
            timeSlider.maximumValue = Float(duration)
            timeSlider.value = Float(elapsedTime)

            timeRemainingLabel.text = "-" + timeIntervalFormatter.string(from: timeRemaining)!
        } else {
            let elapsedTime = audioRecorder?.currentTime ?? 0

            timeElapsedLabel.text = "--:--"

            timeSlider.minimumValue = 0
            timeSlider.maximumValue = 1
            timeSlider.value = 0

            timeRemainingLabel.text = timeIntervalFormatter.string(from: elapsedTime)
        }
    }

    // Timer
    func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }

            self.updateViews()

            if let audioRecorder = self.audioRecorder,
                self.isRecording == true {

                audioRecorder.updateMeters()
                self.audioVisualizer.addValue(decibelValue: audioRecorder.averagePower(forChannel: 0))

            }

            if let audioPlayer = self.audioPlayer,
                self.isPlaying == true {

                audioPlayer.updateMeters()
                self.audioVisualizer.addValue(decibelValue: audioPlayer.averagePower(forChannel: 0))
            }
        }
    }

    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Playback
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: [])
    }

    func play() {
        do {
            try prepareAudioSession()
            audioPlayer?.play()
            updateViews()
            startTimer()
        } catch {
            print("Cannot play audio: \(error)")
        }
    }

    func pause() {
        audioPlayer?.pause()
        updateViews()
        cancelTimer()
    }

    // Recording
    func newRecordingURL() -> URL {
         let fm = FileManager.default
         let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

         let randomId = Int.random(in: 0...1_000_00)

         return documentsDir.appendingPathComponent("TestRecording" + "\(randomId)").appendingPathExtension("caf")
     }

    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else {
                    print("We need microphone access")
                    return
                }

                print("Recording permission has been granted!")
                // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
            }
        case .denied:
            print("Microphone access has been blocked.")

            let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })

            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

            present(alertController, animated: true, completion: nil)
        case .granted:
            startRecording()
        @unknown default:
            break
        }
    }

    func startRecording() {
        do {
            try prepareAudioSession()
        } catch {
            print("Cannot record audio: \(error)")
            return
        }

        recordingURL = newRecordingURL()

        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48_000, channels: 2, interleaved: false)!

        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, format: format)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            updateViews()
            startTimer()
        } catch {
            preconditionFailure("The audio recorder could not be created with \(recordingURL!) and \(format)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        updateViews()
        cancelTimer()
    }

}

extension AudioMemoViewController: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
        cancelTimer()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }
    }

}


extension AudioMemoViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = recordingURL {
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
        }
        cancelTimer()
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error{
            print("Recoder Player Error: \(error)")
        }
    }
}

