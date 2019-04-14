//
//  ViewController.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 04/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NotificationBannerSwift
import ChameleonFramework

class RegistrationViewController: BaseAuthViewController, Coordinatable {
    var coordinator: Coordinator!
    lazy var viewController: UIViewController = {
        return self
    }()

    @IBOutlet weak var nameTF: RoundedTextView!
    @IBOutlet weak var emailTF: RoundedTextView!
    @IBOutlet weak var passwordTF: RoundedTextView!
    @IBOutlet weak var passwordConfirmTF: RoundedTextView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    let viewModel = RegistrationViewModel()
    let disposeBag = DisposeBag()
    
    var isLoading: Bool = false {
        willSet {
            if newValue {
                activityIndicator.startAnimating()
                contentContainer.alpha = 0.1
                activityBtn.isEnabled = false
            } else {
                activityIndicator.stopAnimating()
                contentContainer.alpha = 1
                activityBtn.isEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        view.backgroundColor = GradientColor(.topToBottom, frame: UIScreen.main.bounds, colors: [UIColor(hex: 0x31A343), UIColor(hex: 0xBF0942)])
    }

    override func setupBindings() {
        emailTF.rx.text.orEmpty
            .bind(to: viewModel.emailViewModel.data)
            .disposed(by: disposeBag)
        
        nameTF.rx.text.orEmpty
            .bind(to: viewModel.loginViewModel.data)
            .disposed(by: disposeBag)
        
        passwordTF.rx.text.orEmpty
            .bind(to: viewModel.passwordViewModel.data)
            .disposed(by: disposeBag)
        
        passwordConfirmTF.rx.text.orEmpty
            .bind(to: viewModel.passwordConfirmViewModel.data)
            .disposed(by: disposeBag)
        
        activityBtn.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.view.endEditing(true)
                if self.viewModel.validateCredentials() {
                    self.viewModel.registerUser()
                }
            }).disposed(by: disposeBag)
        
        keyboardHeight()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] keyboardHeight in
                self.moveViewForKeyboard(keyboardHeight: keyboardHeight)
            })
            .disposed(by: disposeBag)
        
        tapGestureRecognizer.rx.event
            .bind(onNext: { [unowned self] recognizer in
                self.view.endEditing(true)
            }).disposed(by: disposeBag)
    }
    
    override func setupCallbacks() {
        viewModel.isSuccess
            .observeOn(MainScheduler.instance)
            .bind { [unowned self] value in
                self.coordinator.performAction(step: .registerSuccess)
            }.disposed(by: disposeBag)
        
        viewModel.errorMsg.asDriver()
            .drive(onNext: { [unowned self] errorMessage in
                if errorMessage.count > 0 {
                    self.showAlertBar(text: errorMessage)
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading.asDriver()
            .drive(onNext: { [unowned self] value in
                self.isLoading = value
            }).disposed(by: disposeBag)
        
        viewModel.errorStep.asDriver()
            .drive(onNext: { [unowned self] value in
                if value.count > 0 {
                    self.showAlertBar(text: value[0].rawValue, style: BannerStyle.warning)
                }
            }).disposed(by: disposeBag)
    }
}

