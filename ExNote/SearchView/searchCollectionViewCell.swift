//
//  searchCollectionViewCell.swift
//  original
//
//  Created by 佐藤紬 on 2021/04/14.
//

import UIKit

class searchCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet var photoImageView : UIImageView!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //cellの枠の幅
        self.layer.borderWidth = 1.0
        // cellの枠の色
        self.layer.borderColor = UIColor.black.cgColor
        // cellを丸くする
        self.layer.cornerRadius = 8.0
        
    }
}
