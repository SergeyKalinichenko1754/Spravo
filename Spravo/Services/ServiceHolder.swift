//
//  ServiceHolder.swift
//  Spravo
//
//  Created by Onix on 9/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation


protocol Service {}

public class ServiceHolder {
    private var servicesDictionary: [String: Service] = [:]
    
    func add<T>(_ protocolType: T.Type, for instance: Service) {
        let name = String(reflecting: protocolType)
        servicesDictionary[name] = instance
    }
    
    func get<T>(by type: T.Type = T.self) -> T {
        return get(by: String(reflecting: type))
    }
    
    private func get<T>(by name: String) -> T {
        guard let service = servicesDictionary[name] as? T else {
            fatalError("firstly you have to add the service")
        }
        return service
    }
    
    func remove<T>(by type: T.Type) {
        let name = String(reflecting: type)
        if let _ = servicesDictionary[name] as? T {
            servicesDictionary[name] = nil
        }
    }
}
