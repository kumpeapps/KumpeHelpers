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

// MARK: saveImage
    public class func saveImage(_ image: UIImage, isBackground: Bool) {

        var imageName = "background.png"

        if !isBackground {
            imageName = "logo.png"
        }

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

// MARK: loadImage
    public class func loadImage(isBackground: Bool) -> UIImage? {

        var imageName = "background.png"

        if !isBackground {
            imageName = "logo.png"
        }

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

    public class func imageToiCloud(image: UIImage, imageName: String, icloudContainerID: String? = nil, imageView: UIImageView? = nil) {
        var imageName = imageName
        if !imageName.contains(".") {
            imageName = "\(imageName).png"
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
            iCloud.shared.saveAndCloseDocument(imageName, with: image.pngData()!, completion: {
                _, data, error in
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
    func imageFromiCloud(imageName: String, defaultImage:UIImage? = nil, icloudContainerID: String? = nil) {
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
        DispatchQueue.global().async {
            iCloud.shared.updateFiles()
            let customImageExists: Bool = iCloud.shared.fileExistInCloud("custom_\(imageName)")
            if customImageExists {
                imageName = "custom_\(imageName)"
                Logger.log(.success, "custom_\(imageName) exists")
            }
            let imageExists: Bool = iCloud.shared.fileExistInCloud(imageName)
            guard imageExists else {
                Logger.log(.error, "\(imageName) does not exist")
                Logger.log(.success, "returning default image")
                self.image = defaultImage
                return
            }
            iCloud.shared.updateFiles()
            iCloud.shared.retrieveCloudDocument(imageName, completion: { _, data, error in
                if error == nil, let filedata: Data = data {
                    Logger.log(.action, "using \(imageName)")
                    self.image = UIImage(data: filedata)!
                    Logger.log(.success, "returned \(imageName)")
                }
            }
            )

        }
    }
}
