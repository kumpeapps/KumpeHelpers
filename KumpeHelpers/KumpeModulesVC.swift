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
    open var titleColor: UIColor = .white
    open var titleFont: UIFont = UIFont(name: "System", size: 17)!

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
        if module.badge != nil {
            cell.badge.text = module.badge!
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
        cell.title.text = module.title
        if !module.isEnabled && module.watermark != nil {
            cell.watermark.image = module.watermark!
            cell.watermark.isHidden = false
         }
        cell.backgroundColor = cellBackgroundColor
        cell.title.textColor = titleColor
        cell.title.font = titleFont
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let module = modules[(indexPath as NSIndexPath).row]
        didSelectModule(module)
    }

    open func didSelectModule(_ module: K_Module) {
        guard module.isEnabled else {
            KumpeHelpers.ShowAlert.messageView(theme: .error, title: "Disabled", message: "\(module.title) is disabled.", seconds: .infinity, invokeHaptics: true)
            return
        }
        if module.action.contains("segue") {
            performSegue(withIdentifier: module.action, sender: self)
        }
    }

}

public struct K_Module {
    let title: String
    let action: String
    let icon: UIImage
    let remoteIconUrl: URL?
    let badge: String?
    let isEnabled: Bool
    let watermark: UIImage?
    public init(title: String, action: String, icon: UIImage, remoteIconURL: URL? = nil, badge: String? = nil, isEnabled: Bool = true, watermark: UIImage? = nil) {
        self.title = title
        self.action = action
        self.icon = icon
        self.remoteIconUrl = remoteIconURL
        self.badge = badge
        self.isEnabled = isEnabled
        self.watermark = watermark
    }
}
