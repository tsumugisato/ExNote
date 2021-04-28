//
//  DetailCollectionViewController.swift
//  original
//
//  Created by 佐藤紬 on 2021/03/13.
//
////
import UIKit
import NCMB
import Kingfisher
import KRProgressHUD

class SecondCollectionViewController: UIViewController{

    var selectednote:NCMBObject!
    var followings = [NCMBUser]()
    var answers = [Answer]()
    

    @IBOutlet var answertextView: UITextView!
    @IBOutlet var questionTextView:UITextView!
    @IBOutlet var sendImage: UIImageView!
    @IBOutlet var userName:UILabel!
    @IBOutlet var comment:UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        let imageUrl = selectednote.object(forKey:"imageUrl") as! String
        sendImage.kf.setImage(with: URL(string: imageUrl))
        answertextView.text = (selectednote.object(forKey: "text") as? String)
        questionTextView.text = (selectednote.object(forKey:"question") as? String)
        let user = selectednote.object(forKey: "user") as! NCMBUser
        userName.text = (user.object(forKey: "displayName") as! String)
        print(selectednote.object(forKey:"question"))
        print(selectednote.object(forKey: "text"))
        
        questionTextView.layer.cornerRadius = 10.0
        answertextView.layer.cornerRadius = 10.0
        userName.layer.cornerRadius = 10.0
        
    }
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {

        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "toanswerComments", sender: nil)
    }
    @IBAction func didTapMenuButton(tableViewCell: UITableViewCell, button: UIBarButtonItem) {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                if UIDevice.current.userInterfaceIdiom == .pad{
                    alertController.popoverPresentationController?.sourceView = self.view
                    let screenSize = UIScreen.main.bounds
                    alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        }
        
                let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
                    KRProgressHUD.show()
                    let query = NCMBQuery(className: "answer")
                    query?.getObjectInBackground(withId: self.answers[tableViewCell.tag].objectId, block: { (post, error) in
                        if error != nil {
                            KRProgressHUD.showError(withMessage: error!.localizedDescription)
                        } else {
//                             取得した投稿オブジェクトを削除
                            post?.deleteInBackground({ (error) in
                                if error != nil {
                                    KRProgressHUD.showError(withMessage: error!.localizedDescription)
                                } else {
//                                     再読込
                                    KRProgressHUD.dismiss()
                                }
                            })
                        }
                    })
                }
        let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
            KRProgressHUD.showSuccess(withMessage:  "この投稿を報告しました。ご協力ありがとうございました。")
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }


            // 他人の投稿なので、報告ボタンを出す
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func Comments(){
        self.performSegue(withIdentifier: "toanswerComments", sender: nil)
    }
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        if segue.identifier == "toanswerComments"{
            let vc = segue.destination as! AnswerCommentViewController
            vc.postId = selectednote.objectId
        }
    }
    
    
}

        
