//
//  PersistBackgrounds.swift
//  KKid
//
//  Created by Justin Kumpe on 9/7/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//
// Saves/loads images to/from device. Will use this in future release so users can setup custom backgrounds/logos.

import UIKit
import iCloudSync

public class PersistBackgrounds {

    /// Saves image to local documents
    public class func saveImage(_ image: UIImage, imageName: String) {

        // Convert to Data
        if let data = image.pngData() {
            // Create URL
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent(imageName)

            do {
                // Write to Disk
                try data.write(to: url)
                Logger.log(.action, "\(imageName) saved to \(url)")

            } catch {
            print("Unable to Write Data to Disk (\(error))")
            }
        }
    }

    /// Loads image from local documents
    public class func loadImage(imageName: String) -> UIImage? {

      let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(imageName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image

        }

        return nil
    }

    /// Saves image to documents in iCloud
    public class func imageToiCloud(image: UIImage, imageName: String, icloudContainerID: String? = nil, imageView: UIImageView? = nil, onlyCustomToCloud: Bool = true) {
        var imageName = imageName
        if !imageName.contains(".") {
            imageName = "\(imageName).png"
        }
        saveImage(image, imageName: imageName)
        guard !onlyCustomToCloud || imageName.contains("custom_") else {
            imageView?.imageFromiCloud(imageName: imageName, defaultImage: image, icloudContainerID: icloudContainerID)
            return
        }
        let cloudIsAvailable: Bool = iCloud.shared.cloudAvailable
        let cloudContainerIsAvailable: Bool = iCloud.shared.ubiquityContainerAvailable
        if (icloudContainerID != nil || !cloudContainerIsAvailable) {
            iCloud.shared.setupiCloud(icloudContainerID)
            Logger.log(.success, "Setup iCloud")
        }
        guard cloudIsAvailable, cloudContainerIsAvailable else {
            Logger.log(.error, "iCloud Not Available")
            if imageView != nil {
                imageView?.imageFromiCloud(imageName: imageName, defaultImage: image, icloudContainerID: icloudContainerID)
            }
            return
        }
        DispatchQueue.global().async {
            iCloud.shared.updateFiles()
            iCloud.shared.saveAndCloseDocument(imageName, with: image.pngData()!, completion: { _, _, error in
                if error == nil {
                    imageView?.imageFromiCloud(imageName: imageName, defaultImage: image, icloudContainerID: icloudContainerID)
                    Logger.log(.success, "Saved \(imageName) to iCloud")
                }
            })
        }
    }
}

// MARK: - UIImageView+imageFromCloud
public extension UIImageView {
    /// Loads image from iCloud documents
    func imageFromiCloud(imageName: String, defaultImage:UIImage? = nil, icloudContainerID: String? = nil, waitForUpdate: Bool = true) {
        let cloudIsAvailable: Bool = iCloud.shared.cloudAvailable
        let cloudContainerIsAvailable: Bool = iCloud.shared.ubiquityContainerAvailable
        var imageName = imageName
        if !imageName.contains(".") {
            imageName = "\(imageName).png"
        }
        if (icloudContainerID != nil || !cloudContainerIsAvailable) {
            iCloud.shared.setupiCloud(icloudContainerID)
            Logger.log(.success, "Setup iCloud")
        }
        guard cloudIsAvailable, cloudContainerIsAvailable else {
            Logger.log(.error, "iCloud Not Available, returning default image")
            self.image = defaultImage
            return
        }
        DispatchQueue.global(qos: .background).async {
            if waitForUpdate {
                iCloud.shared.updateFiles()
            }
            let customImageExists: Bool = iCloud.shared.fileExistInCloud("custom_\(imageName)")
            if customImageExists {
                imageName = "custom_\(imageName)"
                Logger.log(.success, "custom_\(imageName) exists")
            }
            DispatchQueue.main.async {
                self.image = KumpeHelpers.PersistBackgrounds.loadImage(imageName: imageName)
            }
            let imageExists: Bool = iCloud.shared.fileExistInCloud(imageName)
            guard imageExists else {
                Logger.log(.error, "\(imageName) does not exist")
                Logger.log(.success, "returning default image")
                DispatchQueue.main.async {
                    self.image = defaultImage ?? KumpeHelpers.PersistBackgrounds.loadImage(imageName: imageName)
                }
                return
            }
            iCloud.shared.retrieveCloudDocument(imageName, completion: { _, data, error in
                if error == nil, let filedata: Data = data {
                    Logger.log(.action, "using \(imageName)")
                    self.image = UIImage(data: filedata)!
                    Logger.log(.success, "returned \(imageName)")
                    KumpeHelpers.PersistBackgrounds.saveImage(UIImage(data: filedata)!, imageName: imageName)
                    Logger.log(.action, "Saved image to local store for quick retrieving.")
                }
            }
            )

        }
    }
}
