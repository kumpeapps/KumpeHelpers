//
//  KumpeModulesVC.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/11/20.
//

import UIKit
import CollectionViewCenteredFlowLayout
import Kingfisher
import BadgeSwift

open class KumpeModulesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    open var modules:[K_Module] = []
    open var iconWidth:Int = 100
    open var cellBackgroundColor: UIColor = .clear
    open var collectionViewBackgroundColor: UIColor = .clear

    open var collectionView: UICollectionView = {
        var layout = UICollectionViewLayout()
        var cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ModuleCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()

    open func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = CollectionViewCenteredFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = collectionViewBackgroundColor
        collectionView.reloadData()
    }

    open func reloadCollectionView() {
        KumpeHelpers.dispatchOnMain {
            self.collectionView.reloadData()
        }
    }

    // MARK: centerItemsInCollectionView
    open func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }

    // MARK: Set Number of Items
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modules.count
    }

    // MARK: set cell size
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = iconWidth
        return CGSize(width: screenWidth, height: screenWidth)
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let module = modules[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ModuleCollectionViewCell
        cell.watermark.isHidden = true
        cell.badge.isHidden = true
        if module.badge.text != "" {
            cell.badge.text = module.badge.text
            cell.badge.badgeColor = module.badge.badgeColor
            cell.badge.borderColor = module.badge.borderColor
            cell.badge.cornerRadius = module.badge.cornerRadius
            cell.badge.borderWidth = module.badge.borderWidth
            cell.badge.textColor = cell.badge.textColor
            cell.badge.font = cell.badge.font
            cell.badge.isHidden = false
        }
        cell.imageView.image = module.icon
        if module.remoteIconUrl != nil {
            cell.imageView.kf.setImage(
                with: module.remoteIconUrl,
                placeholder: module.icon,
                options: [
                    .transition(.fade(1)),
                    .cacheOriginalImage,
                    .cacheSerializer(FormatIndicatedCacheSerializer.png),
                    .targetCache(ImageCache(name: "iconCache"))
                    ])
        }
        cell.title.text = module.titleLabel.text
        cell.title.textColor = module.titleLabel.textColor
        cell.title.isHidden = module.titleLabel.isHidden
        cell.title.textAlignment = module.titleLabel.textAlignment
        cell.title.font = module.titleLabel.font
        if !module.isEnabled && module.watermark != nil {
            cell.watermark.image = module.watermark!
            cell.watermark.isHidden = false
         }
        cell.backgroundColor = cellBackgroundColor
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let module = modules[(indexPath as NSIndexPath).row]
        didSelectModule(module)
    }

    open func didSelectModule(_ module: K_Module) {
        guard module.isEnabled else {
            KumpeHelpers.ShowAlert.banner(theme: .error, title: "Disabled", message: "\(module.titleLabel.text ?? "Module") is disabled.", seconds: .infinity, invokeHaptics: true)
            return
        }
        if module.action.contains("segue") {
            performSegue(withIdentifier: module.action, sender: self)
        }
    }

}

public struct K_Module {
    public let titleLabel: UILabel
    let action: String
    let icon: UIImage
    let remoteIconUrl: URL?
    public let badge: BadgeSwift
    public let isEnabled: Bool
    let watermark: UIImage?
    public init(title: String, action: String, icon: UIImage, remoteIconURL: URL? = nil, badgeText: String? = nil, isEnabled: Bool = true, watermark: UIImage? = nil) {
        self.titleLabel = UILabel()
        self.titleLabel.text = title
        self.titleLabel.textAlignment = .center
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = UIFont(name: "Marker Felt", size: 17)!
        self.titleLabel.textColor = .white
        self.action = action
        self.icon = icon
        self.remoteIconUrl = remoteIconURL
        self.badge = BadgeSwift()
        self.badge.text = badgeText
        self.badge.translatesAutoresizingMaskIntoConstraints = false
        self.badge.badgeColor = .red
        self.isEnabled = isEnabled
        self.watermark = watermark
    }
}

public struct TitleProperties {
    let font: UIFont
    let color: UIColor
    let alignment: NSTextAlignment
}
