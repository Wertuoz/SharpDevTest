//
//  AppCoordinator.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 08/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import ChameleonFramework
import RxSwift

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
    case userAuthError
    case logoutClicked
    case loginSuccess
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
    case transactionsScreen = "UserTransactionsScreen"
}

enum ScreenTitle: String {
    case authMain = "Authentication"
    case login = "Login"
    case register = "Registration"
    case userMain = "Account"
    case userTransactions = "Transactions"
}

class AppCoordinator {
    private weak var window: UIWindow?
    
    lazy var navigation: UINavigationController = {
        return UINavigationController()
    }()
    
    init(with window: UIWindow) {
        self.window = window
        self.window?.makeKeyAndVisible()

        self.window?.rootViewController = navigation
        navigation.navigationBar.barTintColor = UIColor(hex: 0x31A343)
        navigation.navigationBar.tintColor = UIColor(hex: 0xBF0942)
        navigation.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hex: 0xBF0942),
                                                        NSAttributedString.Key.font: UIFont(name: "Menlo-Bold", size: 17)!]
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Menlo-Bold", size: 10)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Menlo-Bold", size: 10)!], for: .selected)
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
        var vc: Coordinatable = UIStoryboard.instantiateController(for: StoryboardName.login, and: StoryBoardVCNames.autnMainScreen)
        vc.coordinator = self
        vc.viewController.title = ScreenTitle.authMain.rawValue
        navigation.initRootViewController(vc: vc.viewController)
        navigation.setNavigationBarHidden(false, animated: false)
    }
    
    private func navigateToRegistrationScreen() {
        var vc: Coordinatable = UIStoryboard.instantiateController(for: StoryboardName.login, and: StoryBoardVCNames.registrationScreen)
        vc.coordinator = self
        vc.viewController.title = ScreenTitle.register.rawValue
        navigation.pushViewController(vc.viewController, animated: true)
        navigation.setNavigationBarHidden(false, animated: false)
    }
    
    private func navigateToLoginScreen() {
        var vc: Coordinatable = UIStoryboard.instantiateController(for: StoryboardName.login, and: StoryBoardVCNames.loginScreen)
        vc.coordinator = self
        vc.viewController.title = ScreenTitle.login.rawValue
        navigation.pushViewController(vc.viewController, animated: true)
        navigation.setNavigationBarHidden(false, animated: false)
    }
    
    private func navigateToUserScreen() {
        
        var vcUserMain: Coordinatable = UIStoryboard.instantiateController(for: StoryboardName.account, and: StoryBoardVCNames.userMainScreen)
        vcUserMain.coordinator = self
        vcUserMain.viewController.title = ScreenTitle.userMain.rawValue

        var vcUserTransactions: Coordinatable = UIStoryboard.instantiateController(for: StoryboardName.account, and: StoryBoardVCNames.transactionsScreen)
        vcUserTransactions.coordinator = self
        vcUserTransactions.viewController.title = ScreenTitle.userTransactions.rawValue
        
        let tabBarController = UserTabBarViewController(nibName: nil, bundle: nil)
        tabBarController.controllers = [vcUserMain, vcUserTransactions]
        tabBarController.coordinator = self
        
        let tab1Item = UITabBarItem(title: "Account", image: UIImage(named: "usrIcon"), tag: 1)
        let tab2Item = UITabBarItem(title: "Transactions", image: UIImage(named: "moneyIcon"), tag: 2)
        tabBarController.tabs = [tab1Item, tab2Item]
        tabBarController.tabBar.tintColor = UIColor(hex: 0xBF0942)
        tabBarController.tabBar.barTintColor = UIColor(hex: 0x31A343)
        tabBarController.tabBar.unselectedItemTintColor = UIColor.black
        
        navigation.initRootViewController(vc: tabBarController)
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
        case .userAuthError:
            self.performFlow(screen: .navigateToAuthScreen)
        case .logoutClicked:
            UserViewModel.removeAuthToken()
            self.performFlow(screen: .navigateToAuthScreen)
        case .loginSuccess:
            self.performFlow(screen: .navigateToUserScreen)
        }
    }
}
