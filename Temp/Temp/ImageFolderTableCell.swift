//
//  ImageFolderTableCell.swift
//  Temp
//
//  Created by Dustin Winkler on 12.12.21.
//

import UIKit

class ImageFolderTableCell: UITableViewCell {

    @IBOutlet weak var header: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var downloadLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        contentView.layer.cornerRadius = 20
    }
    
}
