//
//  Config.swift
//  MGRemote
//
//  Created by DDS Dev on 2016-06-21.
//  Copyright © 2016 Digital dispatch system. All rights reserved.
//

class Config {
    
    private static let defaultEndpoint : Endpoint = .DEBUG
    private static var currentEndpoint : Endpoint?
    
    enum Endpoint : String {
        case DEBUG = "http://192.168.50.160:78/Service.asmx"
        case QA = "http://192.168.50.144:90/Service.asmx"
        
        static let allValues = [DEBUG, QA]
    }
    
    static func getUrl() -> String {
        return currentEndpoint?.rawValue ?? defaultEndpoint.rawValue
    }
    
    static func getEndpoint() -> Endpoint {
        return currentEndpoint ?? defaultEndpoint
    }
    
    static func switchUrl(endpoint: Endpoint) {
        currentEndpoint = endpoint
    }
}