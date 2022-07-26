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

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    let watermark: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    let title: UILabel = {
        let iv = UILabel()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.textAlignment = .center
        iv.adjustsFontSizeToFitWidth = true
        return iv
    }()
    let badge: BadgeSwift = {
        let iv = BadgeSwift()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.badgeColor = .red
        iv.textColor = .white
        return iv
    }()

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

    open func stopShaking() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "shaking")
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(title)
        contentView.addSubview(badge)
        contentView.addSubview(watermark)
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8).isActive = true
        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8).isActive = true
        title.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        title.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        title.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        badge.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor).isActive = true
        badge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        badge.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        watermark.alpha = 0.4
        watermark.isHidden = true
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

}
