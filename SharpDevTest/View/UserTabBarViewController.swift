//
//  UserTabBarViewController.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 12/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import RxSwift


class UserTabBarViewController: UITabBarController, UITabBarControllerDelegate, Coordinatable {

    var controllers: [Coordinatable]!
    var tabs: [UITabBarItem]!
    
    var coordinator: Coordinator!
    
    lazy var viewController: UIViewController = {
        return self
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        self.setupView()
    }
    
    func setupView() {
        let logoutBtn = UIBarButtonItem.itemWith(colorfulImage: UIImage(named: "logoutIco"), target: self, action: #selector(logoutClicked))
        navigationItem.setRightBarButton(logoutBtn, animated: false)
    }
    
    @objc private func logoutClicked() {
        coordinator.performAction(step: .logoutClicked)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var controllersToRepresent = [UIViewController]()
        
        for i in 0..<controllers.count {
            controllers[i].viewController.tabBarItem = tabs[i]
            controllersToRepresent.append(controllers[i].viewController)
        }
        self.viewControllers = controllersToRepresent
        self.navigationItem.title = controllersToRepresent[0].title
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.navigationItem.title = viewController.title
    }
}
