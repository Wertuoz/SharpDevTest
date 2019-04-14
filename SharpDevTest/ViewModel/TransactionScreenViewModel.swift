//
//  RegistrationViewModel.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 05/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation
import RxSwift

class TransactionScreenViewModel {
    let disposeBag = DisposeBag()

    let isLoading: Variable<Bool> = Variable(false)
    let errorMsg: Variable<String> = Variable("")

    var transactions = [TransactionModel]()
    let transactionsStore = PublishSubject<[TransactionModel]>()
    var user = UserModel()

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
                self.transactionsStore.onNext(transactions!)
            }
        }
    }
    
    func fetchUserInfo() {
        self.isLoading.value = true

        ApiManager.shared.userInfo { [unowned self] (userData, error) in
            self.isLoading.value = false
            if let error = error {
                self.errorMsg.value = error.localizedDescription
                return
            }
            if userData != nil {
                self.user = userData!
            }
        }
    }
    
    func createTransaction(name: String, amount: Int) {
        self.isLoading.value = true
        ApiManager.shared.createTransaction(name: name, amount: amount) { [unowned self] (transactionData, error) in
            self.isLoading.value = false
            if let error = error {
                self.errorMsg.value = error.localizedDescription
                return
            }
            if transactionData != nil {
                self.transactions.append(transactionData!)
                self.transactionsStore.onNext(self.transactions)
                self.fetchUserInfo()
            }
        }
    }
    
    func isBalanceEnough(value: Int) -> Bool {
        if user.balance >= value {
            return true
        } else {
            return false
        }
    }
    
    func getSorter(filter: TransactionFilter) -> (TransactionModel, TransactionModel) -> Bool {
        switch filter {
        case TransactionFilter.date:
            return sortByDate
        case TransactionFilter.name:
            return sortByName
        case TransactionFilter.amount:
            return sortByAmount
        }
    }
    
    func sortByDate(transaction1: TransactionModel, transaction2: TransactionModel) -> Bool {
        return transaction1.stringToDate() > transaction2.stringToDate()
    }
    
    func sortByName(transaction1: TransactionModel, transaction2: TransactionModel) -> Bool {
        return transaction1.userName.count > transaction2.userName.count
    }
    
    func sortByAmount(transaction1: TransactionModel, transaction2: TransactionModel) -> Bool {
        return transaction1.amount > transaction2.amount
    }
    
    func refreshFilter() {
        transactionsStore.onNext(transactions)
    }
}
