//
//  UserCommentsViewController.swift
//  original
//
//  Created by 佐藤紬 on 2021/04/08.
//

import UIKit
import NCMB
import KRProgressHUD
import Kingfisher

class UserCommentsViewController: UIViewController, UITableViewDataSource {
    
    var postId: String!
    
    var comments = [Comment]()
    
    @IBOutlet var commentTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        commentTableView.dataSource = self
        
        commentTableView.tableFooterView = UIView()
        
//        commentTableView.estimatedRowHeight = 110
        
        commentTableView.rowHeight = 90
        
        loadComments()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let userImageView = cell.viewWithTag(1) as! UIImageView
        let userNameLabel = cell.viewWithTag(2) as! UILabel
        let commentLabel = cell.viewWithTag(3) as! UILabel
        // let createDateLabel = cell.viewWithTag(4) as! UILabel
        
        // ユーザー画像を丸く
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        let user = comments[indexPath.row].user
        let userImagePath = "https://mbaas.api.nifcloud.com/2013-09-01/applications/A3RYolrkOGtbzizi/publicFiles/" + user.objectId
        userImageView.kf.setImage(with: URL(string: userImagePath))
        userNameLabel.text = user.displayName
        commentLabel.text = comments[indexPath.row].text
        
        return cell
    }
    //コメントをロード
    func loadComments() {
        comments = [Comment]()
        let query = NCMBQuery(className: "Comment")
        query?.whereKey("postId", equalTo: postId)
        query?.includeKey("user")
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            } else {
                for commentObject in result as! [NCMBObject] {
                    // コメントをしたユーザーの情報を取得
                    let user = commentObject.object(forKey: "user") as! NCMBUser
//                    let displayName = user.object(forKey: "displayName") as! String
//                    let displayName = user.object(forKey: "displayName") as! String
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
//
//                    // コメントの文字を取得
                    let text = commentObject.object(forKey: "text") as! String
                    
                    // Commentクラスに格納
                    let comment = Comment(postId: self.postId, user: userModel, text: text, createDate: commentObject.createDate)
                    self.comments.append(comment)
                    
                    // テーブルをリロード
                    self.commentTableView.reloadData()
                }
                
            }
        })
    }
    
    @IBAction func addComment() {
        let alert = UIAlertController(title: "コメント", message: "コメントを入力して下さい", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            KRProgressHUD.show()
            let object = NCMBObject(className: "Comment")
            object?.setObject(self.postId, forKey: "postId")
            object?.setObject(NCMBUser.current(), forKey: "user")
            object?.setObject(alert.textFields?.first?.text, forKey: "text")
            object?.saveInBackground({ (error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: error!.localizedDescription)
                } else {
                    KRProgressHUD.dismiss()
                    self.loadComments()
                }
            })
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.addTextField { (textField) in
            textField.placeholder = "ここにコメントを入力"
        }
        self.present(alert, animated: true, completion: nil)
    }
}
