//
//  Double.swift
//  Spravo
//
//  Created by Onix on 12/6/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

extension Double {
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = style
        guard let formattedString = formatter.string(from: self) else { return "" }
        return formattedString
    }
    
    func metersIsStringInKm() -> String {
        let formatter = MeasurementFormatter()
        let distanceInMeters = Measurement(value: self, unit: UnitLength.meters)
        return formatter.string(from: distanceInMeters)
    }
}
