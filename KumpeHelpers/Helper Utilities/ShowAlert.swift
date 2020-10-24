//
//  ShowAlert.swift
//  KKid
//
//  Created by Justin Kumpe on 8/17/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//
// @TODO: clean up ShowAlert
// @body: clean up ShowAlert file. create sent alert function to remove duplicate code.

import UIKit
import SwiftMessages
import Haptico

/* MARK: ShowAlert
 Class to hold reusable UIAlerts
*/
public class ShowAlert {

//    Display alert with OK Button
    @available(*, deprecated, message: "banner() or centerView() function is recommended")
    public static func error(viewController: UIViewController, title: String, message: String) {
        // Ensure alert is called on Main incase it is called from background
        dispatchOnMain {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
    }

//    Display alert with completion block
    public static func alertDestructive(viewController: UIViewController, title: String, message: String, okButton: String = "Ok", cancelbutton: String = "Cancel", completion: @escaping (Bool) -> Void) {
        dispatchOnMain {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okButton, style: .destructive, handler: {(_: UIAlertAction!) in completion(true)}))
            alert.addAction(UIAlertAction(title: cancelbutton, style: .default, handler: {(_: UIAlertAction!) in completion(false)}))
            viewController.present(alert, animated: true, completion: nil)
        }
    }

// MARK: - SwiftMessages Alerts
//    Display Top Banner
    public static func banner(theme: Theme = .error, title: String, message: String, seconds: Double = 10, invokeHaptics: Bool = true) {
        
        displayMessage(layout: .cardView, showButton: false, theme: theme, title: title, message: message, windowLevel: .statusBar, presentationStyle: .top, duration: .seconds(seconds: seconds), interfaceMode: .dim, invokeHaptics: invokeHaptics) { (_) in
        }
    }

//    Display Status Bar Banner
    public static func statusLine(theme: Theme = .error, title: String, message: String, seconds: Double = 10, dim: Bool = true, invokeHaptics: Bool = true) {
        dispatchOnMain {
            let view = MessageView.viewFromNib(layout: .statusLine)
            view.button?.isHidden = true
            view.configureTheme(theme)
            view.configureDropShadow()
            view.configureContent(title: title, body: message)
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: .normal)
            config.presentationStyle = .top
            config.duration = .seconds(seconds: seconds)
            if dim {
                config.dimMode = .gray(interactive: true)
            }
            SwiftMessages.show(config: config, view: view)

            if invokeHaptics {
                switch theme {
                case .error: Haptico.shared().generate(.error)
                case .success: Haptico.shared().generate(.success)
                case .warning: Haptico.shared().generate(.warning)
                case .info: return
                }
            }
        }
    }

//    Display Static Status Bar Banner
    public static func statusLineStatic(id: String, theme: Theme = .error, title: String, message: String, blockInterface: Bool = false, invokeHaptics: Bool = false) {
        dispatchOnMain {
            let view = MessageView.viewFromNib(layout: .statusLine)
            view.button?.isHidden = true
            view.configureTheme(theme)
            view.configureDropShadow()
            view.configureContent(title: title, body: message)
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: .normal)
            config.presentationStyle = .top
            config.duration = .forever
            if blockInterface {
                config.dimMode = .gray(interactive: false)
            }
            view.id = id
            SwiftMessages.show(config: config, view: view)

            if invokeHaptics {
                switch theme {
                case .error: Haptico.shared().generate(.error)
                case .success: Haptico.shared().generate(.success)
                case .warning: Haptico.shared().generate(.warning)
                case .info: return
                }
            }
        }
    }

//    Dismisses Static Alert/Banner
    public static func dismissStatic(id: String) {
        dispatchOnMain {
            SwiftMessages.hide(id: id)
        }
    }

//    Display Center Banner
    public static func centerView(theme: Theme = .error, title: String, message: String, seconds: Double = 10, invokeHaptics: Bool = true) {
        dispatchOnMain {
            let view = MessageView.viewFromNib(layout: .centeredView)
            view.button?.isHidden = true
            view.configureTheme(theme)
            view.configureDropShadow()
            view.configureContent(title: title, body: message)
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: .normal)
            config.presentationStyle = .top
            config.duration = .seconds(seconds: seconds)
            config.dimMode = .gray(interactive: true)
            SwiftMessages.show(config: config, view: view)

            if invokeHaptics {
                switch theme {
                case .error: Haptico.shared().generate(.error)
                case .success: Haptico.shared().generate(.success)
                case .warning: Haptico.shared().generate(.warning)
                case .info: return
                }
            }
        }
    }

//    Display Message View Alert
    public static func messageView(theme: Theme = .error, title: String, message: String, seconds: Double = 10, invokeHaptics: Bool = true) {
        dispatchOnMain {
            SwiftMessages.hideAll()
            let view = MessageView.viewFromNib(layout: .messageView)
            view.button?.isHidden = true
            view.configureTheme(theme)
            view.configureDropShadow()
            view.configureContent(title: title, body: message)
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: .normal)
            config.presentationStyle = .top
            config.duration = .seconds(seconds: seconds)
            config.dimMode = .gray(interactive: true)
            SwiftMessages.show(config: config, view: view)

            if invokeHaptics {
                switch theme {
                case .error: Haptico.shared().generate(.error)
                case .success: Haptico.shared().generate(.success)
                case .warning: Haptico.shared().generate(.warning)
                case .info: return
                }
            }
        }
    }

//    Display banner with confirm button and completion closure
    public static func choiceMessage(theme: Theme = .error, title: String, message: String, buttonTitle: String = "Confirm", invokeHaptics: Bool = false, completion: @escaping (Bool) -> Void) {
        dispatchOnMain {
            SwiftMessages.hideAll()
            let view = MessageView.viewFromNib(layout: .messageView)
            var config = SwiftMessages.Config()
            view.configureTheme(theme)
            view.configureContent(title: title, body: message)
            view.button?.setTitle(buttonTitle, for: .normal)
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            view.buttonTapHandler = { _ in SwiftMessages.hide(); completion(true)}
            SwiftMessages.show(config: config, view: view)

            if invokeHaptics {
                switch theme {
                case .error: Haptico.shared().generate(.error)
                case .success: Haptico.shared().generate(.success)
                case .warning: Haptico.shared().generate(.warning)
                case .info: return
                }
            }
        }
    }

//    MARK: displayMessage
    public static func displayMessage(layout: MessageView.Layout, showButton: Bool, theme: Theme, title: String, message: String, windowLevel: UIWindow.Level = .normal, presentationStyle: SwiftMessages.PresentationStyle, duration: SwiftMessages.Duration, interfaceMode: InterfaceMode, invokeHaptics: Bool, completion: @escaping (Bool) -> Void) {
        dispatchOnMain {
            let view = MessageView.viewFromNib(layout: layout)
            view.button?.isHidden = !showButton
            view.configureTheme(theme)
            view.configureDropShadow()
            view.configureContent(title: title, body: message)
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: .normal)
            config.presentationStyle = .top
            config.duration = .seconds(seconds: 1)
            switch interfaceMode {
            case .block:
                config.dimMode = .gray(interactive: false)
            case .dim:
                config.dimMode = .gray(interactive: true)
            case .blur:
                config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            case .blurAndBlock:
                config.dimMode = .blur(style: .dark, alpha: 1, interactive: false)
            default:
                config.dimMode = .none
            }
            if showButton{
                view.buttonTapHandler = { _ in SwiftMessages.hide(); completion(true)}
            }
            SwiftMessages.show(config: config, view: view)

            if invokeHaptics {
                switch theme {
                case .error: Haptico.shared().generate(.error)
                case .success: Haptico.shared().generate(.success)
                case .warning: Haptico.shared().generate(.warning)
                case .info: return
                }
            }
        }
    }
    
//    MARK: InterfaceMode
    public enum InterfaceMode {
        case dim
        case block
        case blur
        case blurAndBlock
        case none
    }

}
