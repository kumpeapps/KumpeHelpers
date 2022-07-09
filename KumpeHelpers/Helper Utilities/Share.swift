//
//  Share.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 7/8/22.
//

import UIKit

public class Share {

    /// Share a URL link- Usage: KumpeHelpers.Share.url("url as string", self)
    public static func url(_ link: String, _ viewController: UIViewController) {
        dispatchOnMain {
            let url = URL(string: link)!
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            viewController.present(activity, animated: true)
        }
    }

    /// Share Text- Usage: KumpeHelpers.Share.url("text as string", self, blockPrint = false)
    public static func text(_ text: String, _ viewController: UIViewController, blockPrint: Bool = false) {
        dispatchOnMain {
            let activity = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            if blockPrint {
                activity.excludedActivityTypes = [UIActivity.ActivityType.print]
            }
            viewController.present(activity, animated: true)
        }
    }

    /// Share an image- Usage: KumpeHelpers.Share.url(UIImage, self, blockPrint = false)
    public static func image(_ image: UIImage, _ viewController: UIViewController, blockPrint: Bool = false) {
        dispatchOnMain {
            let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            if blockPrint {
                activity.excludedActivityTypes = [UIActivity.ActivityType.print]
            }
            viewController.present(activity, animated: true)
        }
    }
}