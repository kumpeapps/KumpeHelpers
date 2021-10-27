//
//  LaunchURL.swift
//  KKid
//
//  Created by Justin Kumpe on 7/25/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit

// MARK: Launch URL
public func launchURL(_ urlString: String?) {
    guard let urlString = urlString else {
        return
    }
    var newUrlString = urlString
    if !urlString.contains("://") {
        newUrlString = "http://\(urlString)"
    }
    guard UIApplication.shared.canOpenURL(URL(string: newUrlString)!) else {
        return
    }
    if let url = URL(string: newUrlString) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
