//
//  ServiceFunctions.swift
//  Spravo
//
//  Created by Onix on 10/23/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

typealias EmptyClosure = () -> ()
typealias SimpleClosure<T> = (T) -> ()

enum Result<V, E> {
    case success(V)
    case failure(E)
}

enum ResultE<E> {
    case success
    case failure(E)
}

enum BoolResult {
    case success(Bool)
    case failure(String)
}


func updateUIonMainThread(block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async { block() }
    }
}
