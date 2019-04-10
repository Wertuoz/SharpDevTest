//
//  UserAuthData.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 04/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation

struct UserAuthData: Decodable {
    var tokenId: String
    
    enum CodingKeys: String, CodingKey {
        case tokenId = "id_token"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tokenId = try container.decode(String.self, forKey: .tokenId)
    }
}
