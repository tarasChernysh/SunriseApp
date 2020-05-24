//
//  Model.swift
//  Sunrise
//
//  Created by Macbook Air 13 on 5/8/19.
//  Copyright © 2019 Ihor Chernysh. All rights reserved.
//

import Foundation

struct Model: Codable {
    let sunrise: String
    let sunset: String
    
    private enum MainCodingKey: String, CodingKey {
        case results
    }
    
    private enum Info: String, CodingKey {
        case sunrise
        case sunset
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MainCodingKey.self)
        let nestedConteiner = try container.nestedContainer(keyedBy: Info.self, forKey: .results)
        self.sunrise = try nestedConteiner.decode(String.self, forKey: .sunrise)
        self.sunset = try nestedConteiner.decode(String.self, forKey: .sunset)
    }
}


