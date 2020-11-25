//
//  ActivityIndicatorView.swift
//  Notes
//
//  Created by Александр Алгашев on 24.11.2020.
//

import UIKit

class ActivityIndicatorLabel: UILabel {
    override var text: String? {
        didSet {
            self.isHidden = self.text == nil || self.text?.isEmpty ?? true
        }
    }
}

class ActivityIndicatorView: UIView {
    @IBOutlet weak var indicatorBackground: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: ActivityIndicatorLabel!
    @IBOutlet weak var messageLabel: ActivityIndicatorLabel!
    
    var title: String? {
        get { self.titleLabel?.text }
        set { self.titleLabel?.text = newValue }
    }
    var message: String? {
        get { self.messageLabel?.text }
        set { self.messageLabel?.text = newValue }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    convenience init(title: String?, message: String?) {
        self.init(frame: .zero)
        
        self.title = title
        self.message = message
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.loadNib()
        self.initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.loadNib()
        self.initialSetup()
    }
    
    private func initialSetup() {
        self.title = nil
        self.message = nil
        
        self.indicatorBackground.layer.cornerRadius = 6
    }
    
    func insertInto(_ view: UIView?) {
        guard let view = view else { return }
        view.addSubview(self)
        frame = view.bounds
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
