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

class UserMainScreenViewController: UIViewController, Coordinatable {
    var coordinator: Coordinator!
    lazy var viewController: UIViewController = {
        return self
    }()
    
    let disposeBag = DisposeBag()
    let viewModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupCallbacks()
        self.view.alpha = 0
        viewModel.fetchUserInfo()
        viewModel.fetchFilteredUsers()
    }
    
    func setupBindings() {
    }
    
    func setupCallbacks() {
        viewModel.isSuccess.asObservable()
            .bind { value in
                print("Successfull")
            }.disposed(by: disposeBag)
        
        viewModel.errorMsg.asDriver()
            .drive(onNext: { errorMessage in
                if errorMessage.count > 0 {
//                    self.showAlertBar(text: errorMessage)
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading.asDriver()
            .drive(onNext: { value in
//                self.isLoading = value
            }).disposed(by: disposeBag)
        
        viewModel.user.asDriver()
            .drive(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
    }
}
