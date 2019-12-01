//
//  Favourite.swift
//  Spravo
//
//  Created by Onix on 11/22/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

enum FavouriteType: String, Codable {
    case phone
    case sms
    case email
}

struct Favourite: Codable {
    var id: String?
    var type: FavouriteType
    var favourite: String
}
