//
//  BlinkEffect.swift
//  PocketLLM
//
//  Created by 문재현 on 2025/06/16.
//
import UIKit
import Foundation

class BlinkEffect {
    
    static func start(on view: UIView) {
        UIView.animate(withDuration: 0.8,
                       delay: 0.0,
                       options: [.repeat, .autoreverse, .allowUserInteraction],
                       animations: { view.alpha = 0.0 },
                       completion: nil)
    }

    static func stop(on view: UIView) {
        view.layer.removeAllAnimations()
        view.alpha = 1.0
    }
}
