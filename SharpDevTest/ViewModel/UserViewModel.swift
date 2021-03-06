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

    let transactionSuccess = PublishSubject<Bool>()
    let isLoading: Variable<Bool> = Variable(false)
    let errorMsg: Variable<String> = Variable("")
    var user: Variable<UserModel> = Variable(UserModel())
    var searchResult = PublishSubject<[UserSearchModel]>()
    let errorStep: Variable<[RegisterErrorStep]> = Variable([RegisterErrorStep]())
    let transactionsStore = PublishSubject<[TransactionModel]>()
    var transactions = [TransactionModel]()
    
    func fetchUserInfo(silent: Bool = false) {
        if silent == false {
            self.isLoading.value = true
        }
        
        ApiManager.shared.userInfo { [unowned self] (userData, error) in
            self.isLoading.value = false
            if let error = error {
                self.errorMsg.value = error.localizedDescription
                return
            }
            if userData != nil {
                self.user.value = userData!
            }
        }
    }
    
    func fetchTransactions() {
        self.isLoading.value = true
        
        ApiManager.shared.fetchTransactions { [unowned self] (transactions, error) in
            self.isLoading.value = false
            if let error = error {
                self.errorMsg.value = error.localizedDescription
                return
            }
            if transactions != nil {
                self.transactions = transactions!
                self.transactionsStore.onNext(self.transactions)
            }
        }
    }
    
    func fetchFilteredUsers(filter: String) {
        self.isLoading.value = true
        ApiManager.shared.filteredUserList(filter: filter) { [unowned self] (searchData, error) in
            self.isLoading.value = false
            if let error = error {
                self.errorMsg.value = error.localizedDescription
                return
            }
            if searchData != nil {
                self.searchResult.onNext(searchData!)
            }
        }
    }
    
    func createTransaction(name: String, amount: Int) {
        ApiManager.shared.createTransaction(name: name, amount: amount) { [unowned self] (transactionData, error) in
            if let error = error {
                self.errorMsg.value = error.localizedDescription
                return
            }
            if transactionData != nil {
                self.transactions.append(transactionData!)
                self.transactionsStore.onNext(self.transactions)
                self.transactionSuccess.onNext(true)
                self.fetchUserInfo()
            }
        }
    }
    
    func isBalanceEnough(value: Int) -> Bool {
        if user.value.balance >= value {
            return true
        } else {
            return false
        }
    }
    
    static func removeAuthToken() {
        let userSettings = UserDefaults.standard
        userSettings.removeObject(forKey: "authToken")
    }
}
