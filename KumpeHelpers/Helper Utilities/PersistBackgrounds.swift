//
//  PersistBackgrounds.swift
//  KKid
//
//  Created by Justin Kumpe on 9/7/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//
//Saves/loads images to/from device. Will use this in future release so users can setup custom backgrounds/logos.

import UIKit

public class PersistBackgrounds {

// MARK: saveImage
    public class func saveImage(_ image: UIImage, isBackground: Bool, isCustom: Bool = false, iCloud: Bool = false, iCloudContainer: String? = nil) {

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
        var documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        if iCloud {
            
            documents = (FileManager.default.url(forUbiquityContainerIdentifier: iCloudContainer)?.appendingPathComponent("Documents"))!
            Logger.log(.codeError, "documents: \(documents)")
            let fileURL = documents.appendingPathComponent("test.txt")
            Logger.log(.codeError, "file: \(fileURL)")

            try? "Hello word".data(using: .utf8)?.write(to: fileURL)

            
        }

        let url = documents.appendingPathComponent(imageName)

        do {
            // Write to Disk
            try data.write(to: url)
            Logger.log(.action, "\(imageName) saved to \(url)")

        } catch {
            Logger.log(.error, "Unable to Write Data to Disk (\(error))")
        }

    }

// MARK: loadImage
    public class func loadImage(isBackground: Bool, iCloud: Bool = false, iCloudContainer: String? = nil) -> UIImage? {

        Logger.log(.action, "loadImage")
        
        var imageName = "background.png"
        var documentsUrl: URL?

        if !isBackground {
            imageName = "logo.png"
        }

        let customImageName = "custom_\(imageName)"

        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if iCloud {
                documentsUrl = FileManager.default.url(forUbiquityContainerIdentifier: iCloudContainer)!.appendingPathComponent("Documents")
            
        } else if let dirPath = paths.first {
            documentsUrl = URL(fileURLWithPath: dirPath)
            let imageUrl = documentsUrl!.appendingPathComponent(imageName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        }

        let imageUrl = documentsUrl!.appendingPathComponent(imageName)
        let image = UIImage(contentsOfFile: imageUrl.path)
        let customImageUrl = documentsUrl!.appendingPathComponent(customImageName)
        let customImage = UIImage(contentsOfFile: customImageUrl.path)
    
        if customImage != nil {
            return customImage
        } else if image != nil {
            return image
        }

        return nil
    }
}
