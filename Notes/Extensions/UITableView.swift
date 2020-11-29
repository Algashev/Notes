//
//  UITableView.swift
//  Notes
//
//  Created by Александр Алгашев on 29.11.2020.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<CellClass: UITableViewCell>(_ cellClass: CellClass.Type, for indexPath: IndexPath) -> CellClass? {
        self.dequeueReusableCell(withIdentifier: "\(CellClass.self)", for: indexPath) as? CellClass
    }
}
