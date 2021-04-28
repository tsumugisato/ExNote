//
//  SearchTableViewCell.swift
//  instasample
//
//  Created by 佐藤紬 on 2021/03/08.
//

import UIKit

protocol SearchTableViewCellDelegate {
    func didTapFollowButton(tableViewCell:UITableViewCell,button:UIButton)

}
class SearchTableViewCell: UITableViewCell {
    
    var delegate:SearchTableViewCellDelegate?
    
    @IBOutlet var userImageView:UIImageView!
    
    @IBOutlet var userNameLabel:UILabel!
    
    @IBOutlet var followButton:UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        followButton.layer.cornerRadius = 10.0
        userImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func follow(button:UIButton) {
        self.delegate?.didTapFollowButton(tableViewCell: self, button: button)
    }
}

