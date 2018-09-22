//
//  BaseNavigationViewController.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 13/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

protocol BaseNavigating {
    func pushViewController(_ viewController: UIViewController, animated: Bool)
    func popViewController(animated: Bool) -> UIViewController?
}

private class BaseNavigationStub: BaseNavigating {
    var viewControllersToPushTo = [UIViewController]()

    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewControllersToPushTo.append(viewController)
    }

    func popViewController(animated: Bool) -> UIViewController? {
        return viewControllersToPushTo.popLast()
    }
}

class BaseNavigationViewController: UINavigationController, BaseNavigating {

    static var navigationController: UINavigationController?

    private static var baseNavigating: BaseNavigating = BaseNavigationStub() {
        willSet(newValue) {
            guard let stub = baseNavigating as? BaseNavigationStub else {
                return
            }

            stub.viewControllersToPushTo.forEach { viewController in
                newValue.pushViewController(viewController, animated: false)
            }
        }
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        type(of: self).navigationController = self
    }

    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        type(of: self).navigationController = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        type(of: self).navigationController = self
    }

    override func viewDidLoad() {
        type(of: self).baseNavigating = self
    }

    class func pushViewController(_ viewController: UIViewController,
                                  animated: Bool,
                                  removePreviousFromStack: Bool = false) {
        if removePreviousFromStack {
            _ = baseNavigating.popViewController(animated: false)
        }

        baseNavigating.pushViewController(viewController, animated: animated)
    }

    class func popViewController(animated: Bool) -> UIViewController? {
        return baseNavigating.popViewController(animated: animated)
    }
}
