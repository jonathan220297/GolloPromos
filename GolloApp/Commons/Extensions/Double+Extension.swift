//
//  Double+Extension.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 2/11/22.
//

import Foundation

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
