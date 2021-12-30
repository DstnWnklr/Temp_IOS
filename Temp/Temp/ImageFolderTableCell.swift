//
//  ImageFolderTableCell.swift
//  Temp
//
//  Created by Dustin Winkler on 12.12.21.
//

import UIKit

class ImageFolderTableCell: UITableViewCell {
    
    @IBOutlet var progressView: UIProgressView!
    
    @IBOutlet weak var header: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var downloadLabel: UILabel!
        
    private static var fortschrittStatic: Float = 0.0
    
    var timer = Timer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 30)
        progressView.setProgress(0.0, animated: true)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.progressViewTestMethode(fortschritt: ImageFolderTableCell.fortschrittStatic)
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        contentView.layer.cornerRadius = 20
    }
    
    func progressViewObserver(fortschritt: Float) {
        ImageFolderTableCell.fortschrittStatic = fortschritt
    }
    
    func progressViewTestMethode(fortschritt: Float) {
        progressView.setProgress(fortschritt, animated: true)
        if(fortschritt >= 1.0) {
            timer.invalidate()
        }
    }
}
