//
//  Target.swift
//  Sunrise
//
//  Created by Macbook Air 13 on 5/8/19.
//  Copyright © 2019 Ihor Chernysh. All rights reserved.
//

import UIKit
import Moya
import CoreLocation

enum Target {
    case info(CLLocationCoordinate2D)
}

extension Target: TargetType {
    var baseURL: URL {
        switch self {
        case .info:
            return URL(string: "https://api.sunrise-sunset.org")!
        }
    }
    
    var path: String {
        switch self {
        case .info:
            return "/json"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .info:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .info(let coordinate):
            return .requestParameters(parameters: ["lat": coordinate.latitude.description,
                                                   "lng": coordinate.longitude.description,
                                                   "formatted": "0"],
                                      encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .info:
            return nil
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
