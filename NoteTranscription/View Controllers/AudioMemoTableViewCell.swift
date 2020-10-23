//
//  AudioMemoTableViewCell.swift
//  NoteTranscription
//
//  Created by Elizabeth Thomas on 10/22/20.
//

import UIKit
import AVFoundation

class AudioMemoTableViewCell: UITableViewCell {

    var recordingURL: URL?
    var audioPlayer: AVAudioPlayer?

    @IBOutlet weak var titleLabel: UILabel!

    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, options: .defaultToSpeaker)
        try session.setActive(true, options: [])
    }

    @IBAction func playButtonTapped(_ sender: Any) {
        do {
            if let recordingURL = recordingURL {
                audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
                guard let audioPlayer = self.audioPlayer else { return }
                audioPlayer.play()
            }
        } catch {
            preconditionFailure("Failure to load audio file at path \(recordingURL!): \(error)")
        }
    }

}
