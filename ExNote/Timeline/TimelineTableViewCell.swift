//
//  TimelineTableViewCell.swift
//  instasample
//
//  Created by 佐藤紬 on 2021/02/28.
//

import UIKit

protocol TimelineTableViewCellDelegate {
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)
    func  didTapgoodButton(tableViewCell:UITableViewCell,button:UIButton)
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapshowfollowerButton(tableViewCell:UITableViewCell,button:UIButton)
    func didTapshowphotoButton(tableViewCell:UITableViewCell,button:UIButton)

}
class TimelineTableViewCell: UITableViewCell {
    
    var delegate : TimelineTableViewCellDelegate?
    
    @IBOutlet var userImageView:UIImageView!
    
    @IBOutlet var userNameLabel:UILabel!
    
    @IBOutlet var photoImageView:UIImageView!
    
    @IBOutlet var likeButton:UIButton!
    
    @IBOutlet var goodButton:UIButton!
    
    @IBOutlet var likeCountLabel:UILabel!
    
    @IBOutlet var goodCountLabel:UILabel!
    
    @IBOutlet var commentTextView:UITextView!
    
    @IBOutlet var timestampLabel:UILabel!
    
    @IBOutlet var commentButton:UIButton!
    
    @IBOutlet var subjectTextField:UITextField!
    
    @IBOutlet var showphotoButton:UIButton!
    
   
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.clipsToBounds = true
        likeButton.layer.cornerRadius = 10.0
        goodButton.layer.cornerRadius = 10.0
        commentTextView.layer.cornerRadius = 10.0
        commentButton.layer.cornerRadius = 10.0
        subjectTextField.layer.cornerRadius = 10.0
        showphotoButton.layer.cornerRadius = 10.0
        

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func like(button: UIButton) {
        self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
    }
    @IBAction func good(button:UIButton){
        self.delegate?.didTapgoodButton(tableViewCell:self,button:button)
    }

    @IBAction func openMenu(button: UIButton) {
        self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
    }

    @IBAction func showComments(button: UIButton) {
        self.delegate?.didTapCommentsButton(tableViewCell: self, button: button)
    }
    @IBAction func showfollowers(button:UIButton) {
        self.delegate?.didTapshowfollowerButton(tableViewCell: self, button: button)
    }
    @IBAction func showphoto(button:UIButton){
        self.delegate?.didTapshowphotoButton(tableViewCell: self, button:button)
        
    }

}
    

