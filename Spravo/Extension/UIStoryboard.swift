//
//  UIStoryboard.swift
//  Spravo
//
//  Created by Onix on 9/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

struct Storyboard {
    static let launch = UIStoryboard(name: "LaunchScreen", bundle: nil)
    static let service = UIStoryboard(name: "ServiceScreens", bundle: nil)
    static let auth = UIStoryboard(name: "AuthFlow", bundle: nil)
}

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self.self)
    }
}

extension UIStoryboard {
    
    func controller<T: UIViewController>(withClass: T.Type) -> T? {
        let identifier = withClass.identifier
        return instantiateViewController(withIdentifier: identifier) as? T
    }
    
    func instantiateViewController<T: StoryboardIdentifiable>() -> T? {
        return instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T
    }
}

