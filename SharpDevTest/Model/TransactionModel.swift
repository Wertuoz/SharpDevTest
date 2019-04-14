//
//  UserData.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 10/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation
import SwiftDate

struct TransactionModel: Decodable {
    var id: Int
    var date, userName: String
    var amount, balance: Int
    
    enum CodingKeys: String, CodingKey {
        case transactionToken = "trans_token"
    }
    
    enum DataCodingKeys: String, CodingKey {
        case id = "id"
        case date = "date"
        case userName = "username"
        case balance = "balance"
        case amount = "amount"
    }
    
    init() {
        self.id = 0
        self.date = ""
        self.userName = ""
        self.balance = 0
        self.amount = 0
    }
    
    init(id: Int, date: String, userName: String, balance: Int, amount: Int) {
        self.id = id
        self.date = date
        self.userName = userName
        self.balance = balance
        self.amount = amount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .transactionToken)
        
        self.id = try dataContainer.decode(Int.self, forKey: .id)
        self.date = try dataContainer.decode(String.self, forKey: .date)
        self.userName = try dataContainer.decode(String.self, forKey: .userName)
        self.balance = try dataContainer.decode(Int.self, forKey: .balance)
        self.amount = try dataContainer.decode(Int.self, forKey: .amount)
    }
    
    
    func stringToDate() -> Date {
        let dateResult = self.date.toDate()
        return dateResult?.date ?? Date()
    }
}
