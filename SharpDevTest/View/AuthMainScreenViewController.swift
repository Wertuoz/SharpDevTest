//
//  AuthMainScreenViewController.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 10/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AuthMainScreenViewController: UIViewController, Coordinatable {
    var coordinator: Coordinator!
    lazy var viewController: UIViewController = {
        return self
    }()
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var loginBtn: RoundedButton!
    @IBOutlet weak var registerBtn: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    func setupBindings() {
        
        loginBtn.rx.tap.subscribe(onNext: { [unowned self] in
            self.coordinator.performAction(step: .loginClicked)
        }).disposed(by: disposeBag)
        
        registerBtn.rx.tap.subscribe(onNext: { [unowned self] in
            self.coordinator.performAction(step: .registerClicked)
        }).disposed(by: disposeBag)
    }
}
