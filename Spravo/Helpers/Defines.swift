//
//  Defines.swift
//  Spravo
//
//  Created by Onix on 9/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

typealias EmptyClosure = () -> ()
typealias SimpleClosure<T> = (T) -> ()

enum Result<V, E> {
    case success(V)
    case failure(E)
}

func updateUIonMainThread(block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async { block() }
    }
}
