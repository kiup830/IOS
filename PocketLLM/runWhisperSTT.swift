//
//  runWhisperSTT.swift
//  PocketLLM
//
//  Created by 문재현 on 2025/06/18.
//
import Foundation


class STTService {
    
    private let bridge = WhisperBridge()
    
    func runWhisperSTT(audioPath: String) -> String {
        let bridge = WhisperBridge()
        let result = bridge.runWhisperOnFile(audioPath)
        return result
    }
    
}



