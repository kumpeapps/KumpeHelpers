//
//  KumpeModulesVC.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/11/20.
//

import UIKit
import CollectionViewCenteredFlowLayout
#if canImport(Kingfisher)
import Kingfisher
#endif

public protocol KumpeModulesVC {
    var collectionView: UICollectionView! { get set }
    var modules:[K_Module] {get set}
    var iconWidth:Int {get set}
    func setupCollectionView()
    func buildModules()
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    func didSelectModule(_ module: K_Module)
}

extension KumpeModulesVC {

    func setupCollectionView() {
        let layout = CollectionViewCenteredFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
    }

    // MARK: centerItemsInCollectionView
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }

    // MARK: Set Number of Items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modules.count
    }

    // MARK: set cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = iconWidth
        return CGSize(width: screenWidth, height: screenWidth)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let module = modules[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ModuleCollectionViewCell
        #if canImport(BadgeSwift)
        cell.badge.isHidden = true
        if module.badge != nil {
            cell.badge.text = module.badge!
            cell.badge.isHidden = false
        }
        #endif
        cell.imageView.image = module.icon
        #if canImport(Kingfisher)
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
        #endif
        cell.title.text = module.title
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let module = modules[(indexPath as NSIndexPath).row]
        didSelectModule(module)
    }

    func didSelectModule(_ module: K_Module) {
        guard module.isEnabled else {
            KumpeHelpers.ShowAlert.messageView(theme: .error, title: "Disabled", message: "\(module.title) is disabled.", seconds: .infinity, invokeHaptics: true)
            return
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
}
