//
//  String.swift
//  Spravo
//
//  Created by Onix on 9/25/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

extension Optional where Wrapped == String {
    var clearedOptional: String? {
        let clearedText = (self ?? "").trimmingCharacters(in: .whitespaces)
        return clearedText.isEmpty ? nil : clearedText
    }
}
