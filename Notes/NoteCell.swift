//
//  NoteCell.swift
//  Notes
//
//  Created by Александр Алгашев on 23.11.2020.
//

import UIKit

class NoteCell: UITableViewCell {
    
    // MARK: - Properties

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    
    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
