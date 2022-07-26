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

    open var modules:[KModule] = []
    open var iconWidth:Int = 100
    open var cellBackgroundColor: UIColor = .clear
    open var collectionViewBackgroundColor: UIColor = .clear
    #warning("Need to set KF icon cache")

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
        #warning("Set KF icon cache expire")
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
        if module.badgeText != nil {
            cell.badge.text = module.badgeText!
            cell.badge.badgeColor = module.settings.badge.badgeColor
            cell.badge.borderColor = module.settings.badge.borderColor
            cell.badge.cornerRadius = module.settings.badge.cornerRadius
            cell.badge.borderWidth = module.settings.badge.borderWidth
            cell.badge.textColor = module.settings.badge.textColor
            cell.badge.font = module.settings.badge.font
            cell.badge.isHidden = false
        }
        cell.imageView.image = module.icon
        if module.remoteIconUrl != nil {
            cell.imageView.kf.setImage(
                with: URL(string: module.remoteIconUrl!),
                placeholder: module.icon,
                options: [
                    .transition(.fade(1)),
                    .cacheOriginalImage,
                    .cacheSerializer(FormatIndicatedCacheSerializer.png),
                    .targetCache(ImageCache(name: "iconCache"))
                    ])
        }
        cell.title.text = module.title
        cell.title.textColor = module.settings.title.textColor
        cell.title.isHidden = module.settings.title.isHidden
        cell.title.textAlignment = module.settings.title.textAlignment
        cell.title.font = module.settings.title.font
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

    open func didSelectModule(_ module: KModule) {
        guard module.isEnabled else {
            KumpeHelpers.ShowAlert.banner(theme: .error, title: "Disabled", message: "\(module.title) is disabled.", seconds: .infinity, invokeHaptics: true)
            return
        }
        if module.action.contains("segue") {
            performSegue(withIdentifier: module.action, sender: self)
        }
    }

}

public struct KModule {
    public var title: String
    public var action: String
    public var icon: UIImage
    public var remoteIconUrl: String?
    public var badgeText: String?
    public var isEnabled: Bool
    public var watermark: UIImage?
    public var settings: KModule_Settings
    public init(title: String, action: String, icon: UIImage, remoteIconURL: String? = nil, badgeText: String? = nil, watermark: UIImage? = nil, isEnabled: Bool = true) {
        self.title = title
        self.action = action
        self.icon = icon
        self.remoteIconUrl = remoteIconURL
        self.badgeText = badgeText
        self.isEnabled = true
        self.watermark = watermark
        self.settings = KModule_Settings()
    }
}

public struct KModule_Settings_Badge {
    public var badgeColor: UIColor = .red
    public var borderColor: UIColor = .red
    public var cornerRadius: CGFloat = -1
    public var borderWidth: CGFloat = 0
    public var textColor: UIColor = .white
    public var font: UIFont = UIFont(name: "Marker Felt", size: 17)!
    public var isHidden: Bool = false
}

public struct KModule_Settings_Title {
    public var textColor: UIColor = .white
    public var isHidden: Bool = false
    public var textAlignment: NSTextAlignment = .center
    public var font: UIFont = UIFont(name: "Helvetica", size: 14)!
}

public struct KModule_Settings {
    public var badge: KModule_Settings_Badge = KModule_Settings_Badge()
    public var title: KModule_Settings_Title = KModule_Settings_Title()
}
