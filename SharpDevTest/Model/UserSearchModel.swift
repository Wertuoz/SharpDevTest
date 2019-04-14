//
//  UserData.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 10/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation

struct UserSearchModel: Decodable {
    var id: Int
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
    
    init() {
        self.id = 0
        self.name = ""
    }

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }
}
