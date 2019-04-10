//
//  PasswordViewModel.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 05/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation
import RxSwift

struct EmailViewModel: ValidationViewModel {
    var errorMessage: String = "Please enter a valid email"
    
    var data: Variable<String> = Variable("")
    var errorValue: Variable<String?> = Variable("")
    
    func validateCredentials() -> Bool {
        let legthValidationResult = validatePattern(text: data.value)
        if legthValidationResult {
            errorValue.value = ""
            return true
        } else {
            errorValue.value = errorMessage
            return false
        }
    }
    
    private func validatePattern(text: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailCheck = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailCheck.evaluate(with:text)
    }
}
