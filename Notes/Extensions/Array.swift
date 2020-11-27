//
//  Array.swift
//  Notes
//
//  Created by Александр Алгашев on 27.11.2020.
//

import Foundation

extension Array where Element : Equatable {
    @discardableResult mutating func remove(_ element: Element) -> Element? {
        guard let index = self.firstIndex(of: element) else { return nil }
        return self.remove(at: index)
    }
}
