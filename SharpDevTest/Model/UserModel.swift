//
//  UserData.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 10/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation

struct UserModel: Decodable {
    var id, balance: Int
    var email, name: String
    
    enum CodingKeys: String, CodingKey {
        case userInfoToken = "user_info_token"
    }
    
    enum DataCodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case email = "email"
        case balance = "balance"
    }
    
    init() {
        self.id = 0
        self.name = ""
        self.email = ""
        self.balance = 0
    }
    
    init(id: Int, email: String, name: String, balance: Int) {
        self.id = id
        self.email = email
        self.name = name
        self.balance = balance
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .userInfoToken)
        
        self.id = try dataContainer.decode(Int.self, forKey: .id)
        self.email = try dataContainer.decode(String.self, forKey: .email)
        self.name = try dataContainer.decode(String.self, forKey: .name)
        self.balance = try dataContainer.decode(Int.self, forKey: .balance)
    }
}
