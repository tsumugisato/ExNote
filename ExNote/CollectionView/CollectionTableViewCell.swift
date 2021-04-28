//
//  CollectionTableViewCell.swift
//  original
//
//  Created by 佐藤紬 on 2021/03/13.
//
import UIKit

protocol CollectionTableViewCellDelegate {
    
}

class CollectionTableViewCell: UITableViewCell{
    

    
    var delegete : CollectionTableViewCellDelegate?
    
    @IBOutlet var userName:UILabel!
    
    @IBOutlet var userImage:UIImageView!
    
    @IBOutlet var questionname:UILabel!
    
    @IBOutlet var timestamp:UILabel!
    
    @IBOutlet var whosequestion:UILabel!
   
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.layer.cornerRadius = userImage.bounds.width / 2.0
        userImage.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
