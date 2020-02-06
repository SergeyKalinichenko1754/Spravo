//
//  Recent.swift
//  Spravo
//
//  Created by Onix on 12/2/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

struct Recent: Codable {
    var beganTalkDate: Date?
    var id: String?
    var type: CommunicationType
    var recipient: String
    var otherRecipients: [String]?
    var completionDate: Date?
}
