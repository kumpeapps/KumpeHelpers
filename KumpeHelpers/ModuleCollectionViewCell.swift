//
//  ModuleCollectionViewCell.swift
//  KKid
//
//  Created by Justin Kumpe on 10/5/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import BadgeSwift

open class ModuleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var watermark: UIImageView!
    @IBOutlet weak var title: UILabel!
    #if canImport(BadgeSwift)
    @IBOutlet weak var badge: BadgeSwift!
    #endif

    var isInEditingMode: Bool = false {
        didSet {
            if isInEditingMode {
                shake()
            } else {
                stopShaking()
            }
        }
    }

    open override var isSelected: Bool {
        didSet {
            // KumpeHelpers.DebugHelpers.notImplementedBanner()
        }
    }

    open func shake() {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.duration = 0.05
        shakeAnimation.repeatCount = 2
        shakeAnimation.autoreverses = true
        let startAngle: Float = (-2) * 3.14159/180
        let stopAngle = -startAngle
        shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
        shakeAnimation.toValue = NSNumber(value: 3 * stopAngle as Float)
        shakeAnimation.autoreverses = true
        shakeAnimation.duration = 0.15
        shakeAnimation.repeatCount = 10000
        shakeAnimation.timeOffset = 290 * drand48()

        let layer: CALayer = self.layer
        layer.add(shakeAnimation, forKey:"shaking")
    }

    func stopShaking() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "shaking")
    }

}
