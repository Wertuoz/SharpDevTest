//
//  RegistrationViewModel.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 05/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation
import RxSwift

enum RegisterErrorStep: String {
    case noErrors = "All fields are ok"
    case loginStep = "Bad login size, try another"
    case emailStep = "Bad email, not valid address"
    case passwordStep = "Bad password size, try longer"
    case passwordConfirmStep = "Passwords do not match in fields"
}

class RegistrationViewModel {
    var model = RegisterModel()
    let disposeBag = DisposeBag()
    
    let emailViewModel = EmailViewModel()
    let passwordViewModel = PasswordViewModel()
    let loginViewModel = LoginViewModel()
    let passwordConfirmViewModel = PasswordViewModel()

    let isSuccess = PublishSubject<Bool>()
    let isLoading: Variable<Bool> = Variable(false)
    let errorMsg: Variable<String> = Variable("")
    let errorStep: Variable<[RegisterErrorStep]> = Variable([RegisterErrorStep]())
    
    func validateCredentials() -> Bool {
        var errors = [RegisterErrorStep]()
        let loginValidationResult = loginViewModel.validateCredentials()
        let emailValidationResult = emailViewModel.validateCredentials()
        let passwordValidationResult = passwordViewModel.validateCredentials()
        var passswordsAreEqual = false
        
        if loginValidationResult == false {
            errors.append(RegisterErrorStep.loginStep)
        }
        if emailValidationResult == false {
            errors.append(RegisterErrorStep.emailStep)
        }
        if passwordValidationResult == false {
            errors.append(RegisterErrorStep.passwordStep)
        }
        if errors.count > 0 {
            self.errorStep.value = errors
        }
        else {
            passswordsAreEqual = passwordConfirmViewModel.data.value == passwordViewModel.data.value
            if passswordsAreEqual == false {
                errors.append(RegisterErrorStep.passwordConfirmStep)
                self.errorStep.value = errors
            }
        }
        return loginValidationResult && emailValidationResult && passwordValidationResult && passswordsAreEqual
    }
    
    func registerUser() {
        model.email = emailViewModel.data.value
        model.password = passwordViewModel.data.value.md5Value
        model.login = loginViewModel.data.value
        
        self.isLoading.value = true
        print(model.password)

        ApiManager.shared.registerUser(userName: model.login, password: model.password, email: model.email) { [unowned self] (authData, error) in
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
