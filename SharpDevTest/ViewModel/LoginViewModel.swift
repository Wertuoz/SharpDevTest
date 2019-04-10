//
//  PasswordViewModel.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 05/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel: ValidationViewModel {
    let minSize = 4
    let maxSize = 12
    
    var errorMessage: String = "Please enter a valid login"
    
    var data: Variable<String> = Variable("")
    var errorValue: Variable<String?> = Variable("")
    
    func validateCredentials() -> Bool {
        let legthValidationResult = validateLength(text: data.value)
        if legthValidationResult {
            errorValue.value = ""
            return true
        } else {
            errorValue.value = errorMessage
            return false
        }
    }
    
    private func validateLength(text: String) -> Bool {
        return (minSize...maxSize).contains(text.count)
    }
}
