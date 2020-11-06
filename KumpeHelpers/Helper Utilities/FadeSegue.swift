//
//  FadeSegue.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 11/5/20.
//

import UIKit

public class FadeSegue: UIStoryboardSegue {

    private var selfRetainer: FadeSegue?

    public override func perform() {
        destination.transitioningDelegate = self
        selfRetainer = self
        destination.modalPresentationStyle = .fullScreen
        source.present(destination, animated: true, completion: nil)
    }
}

extension FadeSegue: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Presenter()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        selfRetainer = nil
        return Dismisser()
    }

    private class Presenter: NSObject, UIViewControllerAnimatedTransitioning {
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 1.5
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let containerView = transitionContext.containerView
            let toView = transitionContext.view(forKey: .to)!

            containerView.addSubview(toView)
            toView.alpha = 0.0
            UIView.animate(withDuration: 1.5,
                           animations: {
                            toView.alpha = 1.0
            },
                           completion: { _ in
                            transitionContext.completeTransition(true)
            }
            )
        }
    }

    private class Dismisser: NSObject, UIViewControllerAnimatedTransitioning {
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.2
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let fromView = transitionContext.view(forKey: .from)!
            UIView.animate(withDuration: 1,
                           animations: {
                            fromView.alpha = 0
            },
                           completion: { _ in
                            transitionContext.completeTransition(true)
            }
            )
        }
    }
}

