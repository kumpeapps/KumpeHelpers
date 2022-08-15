//
//  PersistBackgrounds.swift
//  KKid
//
//  Created by Justin Kumpe on 9/7/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//
//Saves/loads images to/from device. Will use this in future release so users can setup custom backgrounds/logos.

import UIKit
import iCloudSync

public class PersistBackgrounds {

// MARK: saveImage
    public class func saveImage(_ image: UIImage, isBackground: Bool, isCustom: Bool = false, useCloud: Bool = false, iCloudContainer: String? = nil) {

        Logger.log(.action, "saveImage")

        var imageName = "background.png"

        if !isBackground {
            imageName = "logo.png"
        }

        if isCustom {
            imageName = "custom_\(imageName)"
        }

        // Convert to Data
        guard let data = image.pngData() else {
            return
        }

        // Create URL
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        if useCloud {
            iCloud.shared.setupiCloud(iCloudContainer)
            let cloudisAvailable: Bool = iCloud.shared.cloudAvailable
            let cloudContainerIsAvailable: Bool = iCloud.shared.ubiquityContainerAvailable
            guard cloudisAvailable, cloudContainerIsAvailable else {
                saveImage(image, isBackground: isBackground, isCustom: isCustom)
                return
            }
            iCloud.shared.updateFiles()
            iCloud.shared.saveAndCloseDocument(imageName, with: data, completion: {_, _, error in
                if error != nil {
                    saveImage(image, isBackground: isBackground, isCustom: isCustom)
                }
            })
        } else {

            let url = documents.appendingPathComponent(imageName)

            do {
                // Write to Disk
                try data.write(to: url, options: .noFileProtection)
                Logger.log(.action, "\(imageName) saved to \(url)")

            } catch {
                Logger.log(.error, "Unable to Write Data to Disk (\(error))")
            }
        }

    }

// MARK: loadImage
    public class func loadImage(isBackground: Bool, useCloud: Bool = false, iCloudContainer: String? = nil) -> UIImage? {

        Logger.log(.action, "loadImage")
        
        var imageName = "background.png"
        var documentsUrl: URL?
        var icloudImage: UIImage?

        if !isBackground {
            imageName = "logo.png"
        }

        let customImageName = "custom_\(imageName)"

        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if useCloud, let dirPath = FileManager.default.url(forUbiquityContainerIdentifier: iCloudContainer){
            documentsUrl = dirPath.appendingPathComponent("Documents")
        } else if let dirPath = paths.first {
            documentsUrl = URL(fileURLWithPath: dirPath)
        }

        if useCloud {
            iCloud.shared.setupiCloud(iCloudContainer)
            let cloudisAvailable: Bool = iCloud.shared.cloudAvailable
            let cloudContainerIsAvailable: Bool = iCloud.shared.ubiquityContainerAvailable
            guard cloudisAvailable, cloudContainerIsAvailable else {
                return loadImage(isBackground: isBackground)
            }
            iCloud.shared.updateFiles()
            var docName = imageName
            if iCloud.shared.fileExistInCloud(customImageName) {
                docName = customImageName
            }
            guard iCloud.shared.fileExistInCloud(docName) else {
                return loadImage(isBackground: isBackground)
            }
            iCloud.shared.retrieveCloudDocument(docName, completion: {
                document, data, error in
                if error == nil, let fileData: Data = data {
                    icloudImage = UIImage(data: fileData)
                }
                }
            )
        }

        let imageUrl = documentsUrl!.appendingPathComponent(imageName)
        let image = UIImage(contentsOfFile: imageUrl.path)
        let customImageUrl = documentsUrl!.appendingPathComponent(customImageName)
        let customImage = UIImage(contentsOfFile: customImageUrl.path)
    
        if icloudImage != nil {
            return icloudImage
        } else if customImage != nil {
            Logger.log(.action, "Setting Custom Image")
            return customImage
        } else if image != nil {
            Logger.log(.action, "Setting Default Image")
            return image
        }

        if useCloud {
            return loadImage(isBackground: isBackground, useCloud: false)
        }
        Logger.log(.error, "No Image Found")
        return nil
    }

}
