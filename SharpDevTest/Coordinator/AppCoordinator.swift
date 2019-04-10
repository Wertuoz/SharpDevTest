//
//  AppCoordinator.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 08/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import ChameleonFramework

protocol Coordinator {
    func performFlow(screen: FlowStep)
    func performAction(step: FlowAction)
}

protocol Coordinatable {
    var coordinator: Coordinator! { get set }
    var viewController: UIViewController { get }
}

enum FlowAction {
    case loginClicked
    case registerClicked
    case registerSuccess
}

enum FlowStep {
    case navigateToLoginScreen
    case navigateToRegistrationScreen
    case navigateToAuthScreen
    case navigateToUserScreen
}

enum StoryboardName: String {
    case login = "Login"
    case account = "Account"
}

enum StoryBoardVCNames: String {
    case autnMainScreen = "AuthMainScreen"
    case userMainScreen = "UserMainScreen"
    case registrationScreen = "RegistrationScreen"
    case loginScreen = "LoginScreen"
}

enum ScreenTitle: String {
    case authMain = "Authentication"
    case login = "Login"
    case register = "Registration"
    case userMain = "Account"
}

class AppCoordinator {
    private weak var window: UIWindow?
    
    lazy var navigation: UINavigationController = {
        return UINavigationController()
    }()
    
    init(with window: UIWindow) {
        self.window = window
        self.window?.makeKeyAndVisible()
        
        self.window?.backgroundColor = GradientColor(.topToBottom, frame: UIScreen.main.bounds, colors: [UIColor(hex: 0x31A343), UIColor(hex: 0xBF0942)])
        self.window?.rootViewController = navigation
        navigation.navigationBar.barTintColor = UIColor(hex: 0x31A343)
    }
    
    func start() {
        let defaults = UserDefaults.standard
        guard let _ = defaults.string(forKey: SettingsFields.authToken.rawValue) else {
            navigateToAuthScreen()
            return
        }
        navigateToUserScreen()
    }
    
    private func navigateToAuthScreen() {
        navigation.popToRootViewController(animated: false)
        var vc: Coordinatable = UIStoryboard.instantiateController(for: StoryboardName.login, and: StoryBoardVCNames.autnMainScreen)
        vc.coordinator = self
        vc.viewController.title = ScreenTitle.authMain.rawValue
        navigation.pushViewController(vc.viewController, animated: false)
        navigation.setNavigationBarHidden(false, animated: false)
    }
    
    private func navigateToRegistrationScreen() {
        navigation.popToRootViewController(animated: false)
        var vc: Coordinatable = UIStoryboard.instantiateController(for: StoryboardName.login, and: StoryBoardVCNames.registrationScreen)
        vc.coordinator = self
        vc.viewController.title = ScreenTitle.register.rawValue
        navigation.pushViewController(vc.viewController, animated: true)
        navigation.setNavigationBarHidden(false, animated: false)
    }
    
    private func navigateToLoginScreen() {
        navigation.popToRootViewController(animated: false)
        var vc: Coordinatable = UIStoryboard.instantiateController(for: StoryboardName.login, and: StoryBoardVCNames.loginScreen)
        vc.coordinator = self
        vc.viewController.title = ScreenTitle.login.rawValue
        navigation.pushViewController(vc.viewController, animated: true)
        navigation.setNavigationBarHidden(false, animated: false)
    }
    
    private func navigateToUserScreen() {
        navigation.popToRootViewController(animated: false)
        var vc: Coordinatable = UIStoryboard.instantiateController(for: StoryboardName.account, and: StoryBoardVCNames.userMainScreen)
        vc.coordinator = self
        vc.viewController.title = ScreenTitle.userMain.rawValue
        navigation.pushViewController(vc.viewController, animated: true)
        navigation.setNavigationBarHidden(false, animated: false)
    }
}

extension AppCoordinator: Coordinator {
    func performFlow(screen: FlowStep) {
        switch screen {
        case .navigateToAuthScreen:
            self.navigateToAuthScreen()
        case .navigateToLoginScreen:
            self.navigateToLoginScreen()
        case .navigateToRegistrationScreen:
            self.navigateToRegistrationScreen()
        case .navigateToUserScreen:
            self.navigateToUserScreen()
        }
    }
    
    func performAction(step: FlowAction) {
        switch step {
        case .loginClicked:
            self.performFlow(screen: .navigateToLoginScreen)
        case .registerClicked:
            self.performFlow(screen: .navigateToRegistrationScreen)
        case .registerSuccess:
            self.performFlow(screen: .navigateToUserScreen)
        }
    }
}

extension UIStoryboard {
    class func instantiateController<T>(for storyboard: StoryboardName, and screen : StoryBoardVCNames) -> T {
        let storyboard = UIStoryboard.init(name: storyboard.rawValue, bundle: nil);
        return storyboard.instantiateViewController(withIdentifier: screen.rawValue) as! T
    }
}
