//
//  UserData.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 10/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation

struct TransactionListModel: Decodable {
    var transactions: [TransactionListItemModel]
    
    enum CodingKeys: String, CodingKey {
        case transactionToken = "trans_token"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.transactions = try container.decode([TransactionListItemModel].self, forKey: .transactionToken)
    }
}
