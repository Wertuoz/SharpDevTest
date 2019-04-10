//
//  ValidationViewModel.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 05/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation
import RxSwift

protocol ValidationViewModel {
    var errorMessage: String { get }
    
    var data: Variable<String> { get set }
    var errorValue: Variable<String?> { get }
    
    func validateCredentials() -> Bool
}
