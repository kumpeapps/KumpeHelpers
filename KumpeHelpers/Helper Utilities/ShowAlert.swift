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

///    Display alert with OK Button
    @available(*, deprecated, message: "banner() or centerView() function is recommended")
    public static func error(viewController: UIViewController, title: String, message: String) {
        // Ensure alert is called on Main incase it is called from background
        dispatchOnMain {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
    }

///    Display alert with completion block
    public static func alertDestructive(viewController: UIViewController, title: String, message: String, okButton: String = "Ok", cancelbutton: String = "Cancel", completion: @escaping (Bool) -> Void) {
        dispatchOnMain {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okButton, style: .destructive, handler: {(_: UIAlertAction!) in completion(true)}))
            alert.addAction(UIAlertAction(title: cancelbutton, style: .default, handler: {(_: UIAlertAction!) in completion(false)}))
            viewController.present(alert, animated: true, completion: nil)
        }
    }

// MARK: - SwiftMessages Alerts

///    Display Top Banner
    public static func banner(theme: Theme = .error, title: String, message: String, seconds: Double = 10, invokeHaptics: Bool = true) {

        displayMessage(layout: .cardView, showButton: false, theme: theme, alertMessage: AlertMessage.init(title: title, message: message), presentationStyle: .top, duration: .seconds(seconds: seconds), interfaceMode: .dim, invokeHaptics: invokeHaptics) { (_) in
        }

    }

///    Display Status Bar Banner
    public static func statusLine(theme: Theme = .error, title: String, message: String, seconds: Double = 10, dim: Bool = true, invokeHaptics: Bool = true) {

        var interfaceMode: InterfaceMode = .none
        if dim {
            interfaceMode = .dim
        }
        displayMessage(layout: .statusLine, showButton: false, theme: theme, alertMessage: AlertMessage.init(title: title, message: message), presentationStyle: .top, duration: .seconds(seconds: seconds), interfaceMode: interfaceMode, invokeHaptics: invokeHaptics) { (_) in
        }

    }

///    Display Static Status Bar Banner
    public static func statusLineStatic(id: String, theme: Theme = .error, title: String, message: String, blockInterface: Bool = false, invokeHaptics: Bool = false) {

        var interfaceMode: InterfaceMode = .none
        if blockInterface {
            interfaceMode = .block
        }
        displayMessage(layout: .statusLine, showButton: false, theme: theme, alertMessage: AlertMessage.init(title: title, message: message), presentationStyle: .top, duration: .forever, interfaceMode: interfaceMode, invokeHaptics: invokeHaptics, id: id) { (_) in
        }

    }

///    Dismisses Static Alert/Banner
    public static func dismissStatic(id: String) {

        dispatchOnMain {
            SwiftMessages.hide(id: id)
        }

    }

///    Display Center Banner
    public static func centerView(theme: Theme = .error, title: String, message: String, seconds: Double = 10, invokeHaptics: Bool = true) {

        displayMessage(layout: .centeredView, showButton: false, theme: theme, alertMessage: AlertMessage.init(title: title, message: message), presentationStyle: .top, duration: .seconds(seconds: seconds), interfaceMode: .dim, invokeHaptics: invokeHaptics) { (_) in
        }

    }

///    Display Message View Alert
    public static func messageView(theme: Theme = .error, title: String, message: String, seconds: Double = 10, invokeHaptics: Bool = true) {

        displayMessage(layout: .messageView, showButton: false, theme: theme, alertMessage: AlertMessage.init(title: title, message: message), presentationStyle: .top, duration: .seconds(seconds: seconds), interfaceMode: .dim, invokeHaptics: invokeHaptics) { (_) in
        }

    }

///    Display banner with confirm button and completion closure
    public static func choiceMessage(theme: Theme = .error, title: String, message: String, buttonTitle: String = "Confirm", invokeHaptics: Bool = false, completion: @escaping (Bool) -> Void) {

        displayMessage(layout: .messageView, showButton: true, buttonTitle: buttonTitle, theme: theme, alertMessage: AlertMessage.init(title: title, message: message), presentationStyle: .center, duration: .forever, interfaceMode: .blur, invokeHaptics: true) { (success) in
            completion(success)
        }

    }

// MARK: displayMessage
    public static func displayMessage(layout: MessageView.Layout, showButton: Bool, buttonTitle: String = "Confirm", theme: Theme, alertMessage: AlertMessage, presentationStyle: SwiftMessages.PresentationStyle, duration: SwiftMessages.Duration, interfaceMode: InterfaceMode, invokeHaptics: Bool, id: String? = nil, completion: @escaping (Bool) -> Void) {
        dispatchOnMain {
            let view = MessageView.viewFromNib(layout: layout)
            view.button?.isHidden = !showButton
            view.configureTheme(theme)
            view.configureDropShadow()
            view.configureContent(title: alertMessage.title, body: alertMessage.message)
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: .normal)
            config.presentationStyle = .top
            config.duration = duration
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
            if showButton {
                view.buttonTapHandler = { _ in SwiftMessages.hide(); completion(true)}
                view.button?.setTitle(buttonTitle, for: .normal)
            }
            if let id = id {
                view.id = id
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

// MARK: InterfaceMode
    public enum InterfaceMode {
        case dim
        case block
        case blur
        case blurAndBlock
        case none
    }

// MARK: AlertMessage
    public struct AlertMessage {
        let title: String
        let message: String
    }

}
