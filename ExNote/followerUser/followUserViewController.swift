//
//  followUserViewController.swift
//  original
//
//  Created by 佐藤紬 on 2021/04/12.
//

import UIKit
import NCMB
import Kingfisher
import KRProgressHUD
import SwiftDate

class followUserViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, followUserTableViewCellDelegate {
    
    
    var presentuser:NCMBUser!
    var thisUser:User?

    var users = [NCMBUser]()
    var selectedPost: Post?
    var selectedUser: String!
    var posts = [Post]()
    var followings = [NCMBUser]()
    
    var blockedUserIdArray = [String]()
    @IBOutlet var userNameLabel : UILabel!
    @IBOutlet var followLabel : UILabel!
    @IBOutlet var followerLabel : UILabel!
    //@IBOutlet var postLabel : UILabel
    @IBOutlet var userIntroductionTextView : UITextView!
    @IBOutlet var userImageView : UIImageView!
    @IBOutlet var userQuestionTextView:UITextView!
    @IBOutlet var postCountLabel: UILabel!
    @IBOutlet var followerCountLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var usersubject:UITextField!
    @IBOutlet var userwantNote:UITextField!
    @IBOutlet var userfollowTableView:UITableView!
    
    @IBOutlet var wakaruu:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad()","!!!!")
        
        //画像のふちの加工
        userImageView.layer.cornerRadius = userImageView.bounds.width * 0.5
        userImageView.layer.masksToBounds = true
//        loadFollowingInfo()
  
        userfollowTableView.dataSource = self
        userfollowTableView.delegate = self
        let nib = UINib(nibName: "followUserTableViewCell", bundle: Bundle.main)
        userfollowTableView.register(nib, forCellReuseIdentifier: "Cell6")
        
        userQuestionTextView.layer.cornerRadius = 10.0
        userIntroductionTextView.layer.cornerRadius = 10.0
        wakaruu.layer.cornerRadius = 10.0
        loadFollowingUsers()
        loadFollowingUsers()
        setRefreshControl()
        userfollowTableView.rowHeight = 620

        self.userfollowTableView.reloadData()
        self.postCountLabel.text = String(self.posts.count)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear()")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
            self.loadPosts()
        }
//        loadPosts()
        loadFollowingInfo()
        setRefreshControl()
        self.userfollowTableView.reloadData()
        self.postCountLabel.text = String(self.posts.count)
        
        let query = NCMBUser.query()
        query?.whereKey("objectId", equalTo:selectedUser)
        query?.findObjectsInBackground({ [self](result, error) in
            if error != nil{
                print(error)
            }else{
                if let user = NCMBUser.current() {
                userNameLabel.text = thisUser?.displayName
                userIntroductionTextView.text = thisUser?.introduction
                userQuestionTextView.text = thisUser?.question
                usersubject.text = thisUser?.major
                userwantNote.text = thisUser?.wantNote
                    print(posts,"&&&!")
                print(posts,"eeeee")
                    
                    print(thisUser,"66666")
                    print(selectedUser,"7777")
                
                let file = NCMBFile.file(withName: user.objectId , data: nil) as! NCMBFile
                file.getDataInBackground { (data, error) in
                    if error != nil{
                        print(error)

                    } else {
                        if data != nil{
                        let image = UIImage(data: data!)
                        self.userImageView.image = image
                        }
                    }
                }
            }

        }
    })
  }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(posts.count,"8888888888888")
        return posts.count
       
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell6", for: indexPath) as! followUserTableViewCell
        cell.delegate = self
        cell.tag = indexPath.row
        print("99999",posts)
        
          //postからユーザーネームとかを取り出して表示!!
//        let user = post[indexPath.row].user
//               cell.usernameLabel.text = user.userName
//        let userImageUrl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/SsKyQvUQhiLM29yV/publicFiles/" + user.objectId
        
//        cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "photo_placeholder@2x.jpg"), options: nil, progressBlock: nil, completionHandler: nil)

        cell.commentTextView.text = posts[indexPath.row].text
        cell.subjectTextField.text = posts[indexPath.row].subject
        
        let imageUrl = posts[indexPath.row].imageUrl
            cell.photoImageView.kf.setImage(with: URL(string: imageUrl))
        
        

               // Likeによってハートの表示を変える
//               if posts[indexPath.row].isLiked == true {
//                   cell.likeButton.setImage(UIImage(named: "cheers-glass_fill@2x.png"), for: .normal)
//               } else {
//                   cell.likeButton.setImage(UIImage(named: "cheers-glass@2x.png"), for: .normal)
//               }

               // Likeの数
               cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount)件"
               cell.goodCountLabel.text = "\(posts[indexPath.row].goodCount)件"
               // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        cell.timestampLabel.text = posts[indexPath.row].createDate.toString()
                  
        return cell
        print("iiiiiiiii")

    }

    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        if posts[tableViewCell.tag].isLiked == false || posts[tableViewCell.tag].isLiked == nil {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current().objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage: error!.localizedDescription)
                    } else {
                        self.loadPosts()
                    }
                })
            })
        } else {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: error!.localizedDescription)
                } else {
                    post?.removeObjects(in: [NCMBUser.current().objectId], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil {
                            KRProgressHUD.showError(withMessage: error!.localizedDescription)
                        } else {
                            self.loadPosts()
                        }
                    })
                }
            })
        }
    }
    
//    private func reloadTableview() {
//        ///tableviewをリロードする処理
//        self.userfollowTableView.reloadData()
//        self.postCountLabel.text = String(self.posts.count)
//    }

    func didTapgoodButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        if posts[tableViewCell.tag].isgood == false || posts[tableViewCell.tag].isgood == nil {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current().objectId, forKey: "goodUser")
                post?.saveEventually({ [self](error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage: error!.localizedDescription)
                    } else {
                        self.loadPosts()
                    }
                })
            })
        } else {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: error!.localizedDescription)
                } else {
                    post?.removeObjects(in: [NCMBUser.current().objectId], forKey: "goodUser")
                    post?.saveEventually({ (error) in
                        if error != nil {
                            KRProgressHUD.showError(withMessage: error!.localizedDescription)
                        } else {
                            self.loadPosts()
                        }
                    })
                }
            })
        }
    }
    //ここ追加
    @IBAction func wakaru(){
        self.performSegue(withIdentifier: "tosendfollower", sender: nil)
    }
//コメント追加
    @IBAction func Comments(){
        self.performSegue(withIdentifier: "tofollowComments", sender: nil)
    }

    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        if segue.identifier == "tosendfollower"{
            let vc = segue.destination as! SendfollowerViewController
            vc.SecondText = userQuestionTextView.text
        }else if segue.identifier == "tofollowComments"{
//           performSegue(withIdentifier: "toUserComments", sender: nil)
            let commentViewController = segue.destination as! followCommentViewController
            commentViewController.postId = selectedPost?.objectId
        }else if segue.identifier == "tofollowerphoto"{
            let showphoto = segue.destination as! followerphotoViewController
            showphoto.photoId = selectedPost?.objectId
            print("成功")
        }
    }
    //ここ追加
    
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        selectedPost = posts[tableViewCell.tag]

        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "tofollowComments", sender: nil)
    }
    //
    func didTapshowphotoButton(tableViewCell:UITableViewCell,button:UIButton){
        selectedPost = posts[tableViewCell.tag]
        self.performSegue(withIdentifier: "tofollowerphoto", sender: nil)
    }
    func  didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                if UIDevice.current.userInterfaceIdiom == .pad{
                    alertController.popoverPresentationController?.sourceView = self.view
                    let screenSize = UIScreen.main.bounds
                    alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        }
        
                let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
                    KRProgressHUD.show()
                    let query = NCMBQuery(className: "Post")
                    query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
                        if error != nil {
                            KRProgressHUD.showError(withMessage: error!.localizedDescription)
                        } else {
//                             取得した投稿オブジェクトを削除
                            post?.deleteInBackground({ (error) in
                                if error != nil {
                                    KRProgressHUD.showError(withMessage: error!.localizedDescription)
                                } else {
//                                     再読込
                                    self.loadPosts()
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
    
    func loadPosts(){
//        guard let currentUser = thisUser else{
//            //ストーリーボードの取得
//            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
//            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
//            //このアプリの一番奥の画面の取得
//            UIApplication.shared.keyWindow?.rootViewController = rootViewController
//
//            //次の立ち上げでSignInを指すようにする!!
//            let ud = UserDefaults.standard
//            //SceneDelegateのところ、login成功　していない時はfalseだったからそれを書く!!
//            ud.set(false, forKey: "isLogin")
//            ud.synchronize()
//            return
//        }
       
        guard let userObject = presentuser
        else{return}
        print(userObject,"rrrrr")
        print(NCMBUser.current())
        print(thisUser,"ttttt")
        
        
        let query = NCMBQuery(className: "Post")
        //Userの情報もpostと同時に取ってくる
        query?.includeKey("user")
        
        
        print(presentuser,"&&&&&&&&")
        query?.whereKey("user", equalTo:presentuser)
        print("--------------AHOY!!!!!---------------")
//        print(userId)
    
        self.loadFollowingInfo()
        self.setRefreshControl()
        //投稿順
        query?.order(byDescending: "createDate")
        // オブジェクトの取得
        query?.findObjectsInBackground({ (result, error) in
            print(result,"#####")
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            } else {
                // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
                self.posts = [Post]()

                for postObject in result as! [NCMBObject] {
                 print(result)
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser

                    //退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                    if user.object(forKey: "active") as? Bool != false {
                        // 投稿したユーザーの情報をUserモデルにまとめる
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        //userModel.displayName = user.object(forKey: "displayName") as? String

                        // 投稿の情報を取得
                        let imageUrl = postObject.object(forKey: "imageUrl") as! String
                        let text = postObject.object(forKey: "text") as! String
                        let subject = postObject.object(forKey: "subject") as! String
                     

                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                        let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl,text:text, createDate: postObject.createDate,subject:subject)
                    

                        // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                        let likeUsers = postObject.object(forKey: "likeUser") as? [String]
                        if likeUsers?.contains(NCMBUser.current().objectId) == true {
                         post.isLiked = true
                       
                            
                        } else {
                            post.isLiked = false
                        }

                        // いいねの件数
                        if let likes = likeUsers {
                            post.likeCount = likes.count
                        }
                        let goodUsers = postObject.object(forKey: "goodUser") as? [String]
                        if goodUsers?.contains(NCMBUser.current().objectId) == true {
                         post.isgood = true
                       
                            
                        } else {
                            post.isgood = false
                        }

                        // いいねの件数
                        if let goods = goodUsers {
                            post.goodCount = goods.count
                        }

                        // 配列に加える
                        if self.blockedUserIdArray.firstIndex(of: post.user.objectId) == nil{
                        self.posts.append(post)
                            print("----------------post2222-------------------")
                            print(post)
                            
                    }
                }
                }

                // 投稿のデータが揃ったらTableViewをリロード
                self.userfollowTableView.reloadData()
                self.postCountLabel.text = String(self.posts.count)
                print(self.userfollowTableView.reloadData(),"hhh")
            }
        })
//        self.userfollowTableView.reloadData()
//        self.postCountLabel.text = String(self.posts.count)
    }
    
   
    
  
  
    func loadFollowingInfo() {
        
        let query = NCMBUser.query()
        query?.whereKey("objectId", equalTo: selectedUser)
        query?.findObjectsInBackground({ [self] (result, error) in
            if error != nil{
                print(error)
            }else{
                presentuser = result?[0] as! NCMBUser
            
                
                print("-------userId--------")
                print(presentuser,"%%%%%%%%%%")
                
                //フォロー機能せず
                let followingQuery = NCMBQuery(className: "Follow")
                followingQuery?.includeKey("user")
                followingQuery?.whereKey("user", equalTo: presentuser)
                followingQuery?.countObjectsInBackground({ (count, error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage: error!.localizedDescription)
                    } else {
                        // 非同期通信後のUIの更新はメインスレッドで
                        DispatchQueue.main.async {
                            self.followLabel.text = String(count)
                        }
                    }
                })
                
                // フォロワー
                let followerQuery = NCMBQuery(className: "Follow")
                followerQuery?.includeKey("following")
                followerQuery?.whereKey("following", equalTo: presentuser)
                followerQuery?.countObjectsInBackground({ (count, error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage:  error!.localizedDescription)
                    } else {
                        DispatchQueue.main.async {
                            // 非同期通信後のUIの更新はメインスレッドで
                            self.followerLabel.text = String(count)
                        }
                    }
                })
            }
        })
    }
    func loadFollowingUsers() {
        // フォロー中の人だけ持ってくる
        guard let currentUser = NCMBUser.current() else {
                    
                    //                    ログアウト成功
                    let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    //                    ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                    
                    return
                }
        let query = NCMBQuery(className: "Follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user", equalTo: selectedPost?.user)
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            } else {
                self.followings = [NCMBUser]()
                for following in result as! [NCMBObject] {
                    self.followings.append(following.object(forKey: "following") as! NCMBUser)
                }
                self.followings.append(NCMBUser.current())
                
            }
        })
    }
    func setRefreshControl() {
            let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
            userfollowTableView?.addSubview(refreshControl)
        }

    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
            refreshControl.beginRefreshing()
//            self.loadFollowimgUser()
        self.loadPosts()
            // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                refreshControl.endRefreshing()
            }
    }

}
//
//extension followUserViewController: delegate, datasourvce {
//

//kokonikakku
//
//}
