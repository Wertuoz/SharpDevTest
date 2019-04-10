//
//  RegistrationViewModel.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 05/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation
import RxSwift

class UserViewModel {
    let disposeBag = DisposeBag()

    let isSuccess: Variable<Bool> = Variable(false)
    let isLoading: Variable<Bool> = Variable(false)
    let errorMsg: Variable<String> = Variable("")
    var user: Variable<UserModel> = Variable(UserModel())
    let errorStep: Variable<[RegisterErrorStep]> = Variable([RegisterErrorStep]())
    
    func fetchUserInfo() {
        self.isLoading.value = true
        
        ApiManager.shared.userInfo { [weak self] (userData, error) in
            if let error = error {
                self?.isLoading.value = false
                self?.isSuccess.value = false
                self?.errorMsg.value = error.localizedDescription
                return
            }
            if userData != nil {
                self?.isLoading.value = false
                self?.isSuccess.value = true
                self?.user.value = userData!
            } else {
                self?.isLoading.value = false
                self?.isSuccess.value = false
            }
        }
    }
    
    func fetchFilteredUsers() {
        ApiManager.shared.filteredUserList(filter: "tro") { [weak self] (data, error) in
            if let error = error {
                self?.isLoading.value = false
                self?.isSuccess.value = false
                self?.errorMsg.value = error.localizedDescription
                return
            }
            if data != nil {
                self?.isLoading.value = false
                self?.isSuccess.value = true
//                self?.user.value = userData!
            } else {
                self?.isLoading.value = false
                self?.isSuccess.value = false
            }
        }
        
    }
}
