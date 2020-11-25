//
//  UIView.swift
//  Notes
//
//  Created by Александр Алгашев on 23.11.2020.
//

import UIKit

// MARK: - Load from Xib

extension UIView {
    private func getViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let bundleObjects = bundle.loadNibNamed(nibName, owner: self)
        let view = bundleObjects?.first as! UIView
        return view
    }
    
    func loadNib() {
        let view = getViewFromNib()
        addSubview(view)
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
