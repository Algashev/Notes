//
//  UIAlertController.swift
//  Notes
//
//  Created by Александр Алгашев on 22.11.2020.
//

import UIKit

extension UIAlertController {
    convenience init(title: String?, message: String?) {
        self.init(title: title, message: message, preferredStyle: .alert)
    }
    
    @discardableResult
    func addAction(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        self.addAction(action)
        
        return action
    }
}
