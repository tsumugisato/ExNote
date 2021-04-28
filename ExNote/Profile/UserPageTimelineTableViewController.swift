//
//  UserPageTimelineTableViewController.swift
//  original
//
//  Created by 佐藤紬 on 2021/04/05.
//
import UIKit

protocol UserPageTimelineTableViewCellDelegate {
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)
    func  didTapgoodButton(tableViewCell:UITableViewCell,button:UIButton)
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapshowphotoButton(tableViewCell:UITableViewCell,button:UIButton)


}
class UserPageTimelineTableViewCell: UITableViewCell {
    
    var delegate : UserPageTimelineTableViewCellDelegate?
    
    @IBOutlet var likeButton:UIButton!
    
    @IBOutlet var goodButton:UIButton!
    
    @IBOutlet var likeCountLabel:UILabel!
    
    @IBOutlet var goodCountLabel:UILabel!
    
    @IBOutlet var commentTextView:UITextView!
    
    @IBOutlet var timestampLabel:UILabel!
    
    @IBOutlet var commentButton:UIButton!
    
    @IBOutlet var subjectTextField:UITextField!
    
    @IBOutlet var photoImageView:UIImageView!
   
    @IBOutlet var showphoto:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        likeButton.layer.cornerRadius = 10.0
        goodButton.layer.cornerRadius = 10.0
        commentTextView.layer.cornerRadius = 10.0
        commentButton.layer.cornerRadius = 10.0
        subjectTextField.layer.cornerRadius = 10.0
        showphoto.layer.cornerRadius = 10.0
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
    @IBAction func showphoto(button:UIButton){
        self.delegate?.didTapshowphotoButton(tableViewCell: self, button:button)
        
    }
    
}
