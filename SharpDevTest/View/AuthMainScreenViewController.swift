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
import ChameleonFramework

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
        setupView()
        setupBindings()
    }
    
    func setupView() {
        view.backgroundColor = GradientColor(.topToBottom, frame: UIScreen.main.bounds, colors: [UIColor(hex: 0x31A343), UIColor(hex: 0xBF0942)])
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
