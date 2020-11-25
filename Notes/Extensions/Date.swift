//
//  Date.swift
//  Notes
//
//  Created by Александр Алгашев on 25.11.2020.
//

import Foundation

extension Date {
    func string(dateStyle: DateFormatter.Style = .short,
                timeStyle: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
