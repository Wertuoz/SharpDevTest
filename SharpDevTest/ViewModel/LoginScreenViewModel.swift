//
//  LoginScreenViewModel.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 08/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation
import RxSwift

enum LoginErrorStep: String {
    case noErrors = "All fields are ok"
    case emailStep = "Bad email, not valid address"
    case passwordStep = "Bad password size, try longer"
}

class LoginScreenViewModel {
    
    var model = LoginModel()
    var emailViewModel = EmailViewModel()
    var passwordViewModel = PasswordViewModel()
    
    let isSuccess = PublishSubject<Bool>()
    let isLoading: Variable<Bool> = Variable(false)
    let errorMsg: Variable<String> = Variable("")
    let errorStep: Variable<[LoginErrorStep]> = Variable([LoginErrorStep]())
    
    func validateCredentials() -> Bool {
        var errors = [LoginErrorStep]()
        let emailValidationResult = emailViewModel.validateCredentials()
        let passwordValidationResult = passwordViewModel.validateCredentials()

        if emailValidationResult == false {
            errors.append(LoginErrorStep.emailStep)
        }
        if passwordValidationResult == false {
            errors.append(LoginErrorStep.passwordStep)
        }
        if errors.count > 0 {
            self.errorStep.value = errors
        }

        return emailValidationResult && passwordValidationResult
    }
    
    func loginUser() {
        model.email = emailViewModel.data.value
        model.password = passwordViewModel.data.value.md5Value
        
        self.isLoading.value = true
        
        ApiManager.shared.loginUser(email: model.email, password: model.password) { [unowned self] (authData, error) in
             self.isLoading.value = false
            if let error = error {
                self.errorMsg.value = error.localizedDescription
                return
            }
            if authData != nil {
                self.saveToken(authToken: authData!.tokenId)
                self.isSuccess.onNext(true)
            }
        }
    }
    
    func saveToken(authToken: String) {
        let userSettings = UserDefaults.standard
        userSettings.setValue(authToken, forKey: "authToken")
    }
}
