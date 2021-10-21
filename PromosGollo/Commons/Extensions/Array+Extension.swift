//
//  Array+Extension.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation

extension Array {

    func evenlySpaced(length: Int) -> [Element] {
        guard length < self.count else { return self }

        let takeIndex = (self.count / length) - 1
        let nextArray = Array(self.dropFirst(takeIndex + 1))
        return [self[takeIndex]] + nextArray.evenlySpaced(length: length - 1)
    }

}
