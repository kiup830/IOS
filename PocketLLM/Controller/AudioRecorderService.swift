//
//  AudioRecorderService.swift
//  PocketLLM
//
//  Created by 문재현 on 2025/06/18.
//

import Foundation
import AVFoundation

class AudioRecorderService: NSObject, AVAudioRecorderDelegate {
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession!
    
    var outputURL: URL?
    
    override init() {
        
        super.init()
        recordingSession = AVAudioSession.sharedInstance()
        
        print("🎧 입력 가능 상태: \(AVAudioSession.sharedInstance().isInputAvailable)")
        
        try? recordingSession.setCategory(.playAndRecord, mode: .default)
        try? recordingSession.setActive(true)
        
        createAudioFolderIfNeeded()
        
    }
    
    // audio 폴더 생성 함수
    private func createAudioFolderIfNeeded() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFolderURL = documentsDirectory.appendingPathComponent("audio")

        if !FileManager.default.fileExists(atPath: audioFolderURL.path) {
            do {
                try FileManager.default.createDirectory(at: audioFolderURL, withIntermediateDirectories: true)
                print("✅ audio 폴더 생성됨: \(audioFolderURL.path)")
            } catch {
                print("❌ audio 폴더 생성 실패: \(error)")
            }
        }
    }
    
    // 녹음 실행 및 녹음 오디오 파일 경로 반환 함수
    func startRecording() -> URL? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMdd_HHmmss"
        
        let timestamp = formatter.string(from: Date())
        
        let fileName = "audio_\(timestamp).wav"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFolderURL = documentsDirectory.appendingPathComponent("audio")
        let audioURL = audioFolderURL.appendingPathComponent(fileName)
        outputURL = audioURL

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM), // .wav 포맷용
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            print("녹음 시작 -> \(audioURL.path)")
            return audioURL
            
        } catch {
            
            print("녹음 실패 -> \(error)")
            return nil
        }
        
        
    }
            
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
}
    
    

