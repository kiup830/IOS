//
//  PaddingLabel.swift
//  PocketLLM
//
//  Created by 문재현 on 2025/06/18.
//

import Foundation

import UIKit

class PaddingLabel: UILabel {

    var inset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + inset.left + inset.right,
                      height: size.height + inset.top + inset.bottom)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let adjustedSize = super.sizeThatFits(size)
        return CGSize(width: adjustedSize.width + inset.left + inset.right,
                      height: adjustedSize.height + inset.top + inset.bottom)
    }
}
