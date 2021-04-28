//
//  UserPageViewController.swift
//  instasample
//
//  Created by 佐藤紬 on 2021/02/20.
//


import UIKit
import NCMB
import Kingfisher
import KRProgressHUD
import NYXImagesKit

class UserPageViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UserPageTimelineTableViewCellDelegate{
    
    
    
    var posts = [Post]()
    
    var selectedMemo:String!

    var selectedPost: Post?
    
    var followings = [NCMBUser]()
    
    var users = [User]()
    
    var postUser:User?
    var blockedUserIdArray = [String]()
    
    @IBOutlet var userImageView: UIImageView!
    
    
    @IBOutlet var userDisplayNameLabel: UILabel!
    
    @IBOutlet var userIntroductionTextView: UITextView!
    
    @IBOutlet var userQuestionTextView:UITextView!
    
    
    @IBOutlet var postCountLabel: UILabel!
    
    @IBOutlet var followerCountLabel: UILabel!
    
    @IBOutlet var followingCountLabel: UILabel!
    
    @IBOutlet var editButton:UIButton!
    
    @IBOutlet var usersubject:UITextField!
    
    @IBOutlet var userwantnote:UITextField!
    
    @IBOutlet var UserPagetimelineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postCountLabel.text = String(posts.count)
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        userIntroductionTextView.layer.cornerRadius = 10.0
        userQuestionTextView.layer.cornerRadius = 10.0
        editButton.layer.cornerRadius = 10.0
        
       
        
//        collectionViewFlowLayout.estimatedItemSize = CGSize(width: photoCollectionView.frame.width / 3, height: photoCollectionView.frame.height / 3)
//        collectionViewFlowLayout.itemSize = CGSize(width: photoCollectionView.frame.width / 2, height:photoCollectionView.frame.height / 3)
        UserPagetimelineTableView.dataSource = self
        UserPagetimelineTableView.delegate = self

        let nib = UINib(nibName: "UserPageTimelineTableViewCell", bundle: Bundle.main)
        UserPagetimelineTableView.register(nib, forCellReuseIdentifier: "Cell4")
        
        UserPagetimelineTableView.tableFooterView = UIView()
        // 引っ張って更新
        setRefreshControl()
        print(setRefreshControl(),"33")
        // フォロー中のユーザーを取得する。その後にフォロー中のユーザーの投稿のみ読み込み
        loadFollowingUsers()
        print(loadFollowingUsers(),"555")
        UserPagetimelineTableView.rowHeight = 620
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTimeline()
        loadFollowingInfo()
        setRefreshControl()
        postCountLabel.text = String(posts.count)
        print(NCMBUser.current())
        if let user = NCMBUser.current() {
            userDisplayNameLabel.text = user.object(forKey: "displayName") as? String
            userIntroductionTextView.text = user.object(forKey: "introduction") as? String
            userQuestionTextView.text = user.object(forKey: "question") as? String
            usersubject.text = user.object(forKey: "major") as? String
            userwantnote.text = user.object(forKey: "wantNote") as? String
            postCountLabel.text = String(posts.count)
            self.navigationItem.title = user.userName
            
            
            let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
            file.getDataInBackground { (data, error) in
                if error != nil {
                    let alert = UIAlertController(title: "画像取得エラー", message: error!.localizedDescription, preferredStyle: .alert)
              
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if data != nil {
                        let image = UIImage(data: data!)
                        self.userImageView.image = image
                    }
                }
            }
        } else {
            // NCMBUser.current()がnilだったとき
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
         UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            // ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell4") as! UserPageTimelineTableViewCell
        let imageUrl = posts[indexPath.row].imageUrl
        cell.photoImageView.kf.setImage(with: URL(string: imageUrl))
        cell.delegate = self
        cell.tag = indexPath.row

        cell.commentTextView.text = posts[indexPath.row].text
        cell.subjectTextField.text = posts[indexPath.row].subject
        
        // Likeによってハートの表示を変える
        if posts[indexPath.row].isLiked == true {
            cell.likeButton.setImage(UIImage(named: "heart-fill"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "heart-outline"), for: .normal)
        }
        
        // Likeの数
        cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount)件"
        
        cell.goodCountLabel.text = "\(posts[indexPath.row].goodCount)件"
        
        
        
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        cell.timestampLabel.text = posts[indexPath.row].createDate.toString()
        return cell
    }

//
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        if posts[tableViewCell.tag].isLiked == false || posts[tableViewCell.tag].isLiked == nil {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current().objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage: error!.localizedDescription)
                    } else {
                        self.loadTimeline()
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
                            self.loadTimeline()
                        }
                    })
                }
            })
        }
    }
    func didTapgoodButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        if posts[tableViewCell.tag].isgood == false || posts[tableViewCell.tag].isgood == nil {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current().objectId, forKey: "goodUser")
                post?.saveEventually({ [self] (error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage: error!.localizedDescription)
                    } else {
                        self.loadTimeline()
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
                            self.loadTimeline()
                        }
                    })
                }
            })
        }
    }
//

    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
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
                    // 取得した投稿オブジェクトを削除
                    post?.deleteInBackground({ (error) in
                        if error != nil {
                            KRProgressHUD.showError(withMessage: error!.localizedDescription)
                        } else {
                            // 再読込
                            self.loadTimeline()
                            KRProgressHUD.dismiss()
                        }
                    })
                }
            })
        }
        let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
            KRProgressHUD.showSuccess(withMessage: "この投稿を報告しました。ご協力ありがとうございました。")
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        if posts[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
            // 自分の投稿なので、削除ボタンを出す
            alertController.addAction(deleteAction)
        } else {
            // 他人の投稿なので、報告ボタンを出す
            alertController.addAction(reportAction)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }


    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        // 選ばれた投稿を一時的に格納
        selectedPost = posts[tableViewCell.tag]

        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "toUserComments", sender: nil)
    }
    func didTapshowphotoButton(tableViewCell:UITableViewCell,button:UIButton){
        selectedPost = posts[tableViewCell.tag]
        self.performSegue(withIdentifier: "toshowphoto2", sender: nil)
    }
    
        // 新着ユーザー50人だけ拾う
//    　　 query?.limit = 50
//        query?.order(byDescending: "createDate")
//
//        query?.findObjectsInBackground({ (result, error) in
//            if error != nil {
//                SVProgressHUD.showError(withStatus: error!.localizedDescription)
//            } else {
//                 取得した新着50件のユーザーを格納
//                self.users = result as! [NCMBUser]
//                print(result)
//                self.loadFollowingUserIds()
    
    func loadTimeline() {
        guard let currentUser = NCMBUser.current() else{
            //ストーリーボードの取得
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            //このアプリの一番奥の画面の取得
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            //次の立ち上げでSignInを指すようにする!!
            let ud = UserDefaults.standard
            //SceneDelegateのところ、login成功　していない時はfalseだったからそれを書く!!
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            return
        }
        let userObject = NCMBUser.current()
        let query = NCMBQuery(className: "Post")
        // 降順
//        query?.order(byDescending: "createDate")
        
        // 投稿したユーザーの情報も同時取得
        query?.includeKey("user")
        // フォロー中の人 + 自分の投稿だけ持ってくる
        query?.whereKey("user", equalTo: userObject)
        query?.order(byDescending: "createDate")
        // オブジェクトの取得
        query?.findObjectsInBackground({ [self] (result, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            } else {
                // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    
                    // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                    if user.object(forKey: "active") as? Bool != false {
                        // 投稿したユーザーの情報をUserモデルにまとめる
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        userModel.introduction = user.object(forKey: "introduction") as? String
                        userModel.question = user.object(forKey: "question") as? String
                        userModel.major = user.object(forKey: "major") as? String
                        userModel.wantNote = user.object(forKey: "wantNote") as? String
                        // 投稿の情報を取得
                        let imageUrl = postObject.object(forKey: "imageUrl") as! String
                        let text = postObject.object(forKey: "text") as! String
                        let subject = postObject.object(forKey: "subject") as! String
                        
                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                        let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate,subject:subject)
                        
                        // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                        let likeUsers = postObject.object(forKey: "likeUser") as? [String]
                        if likeUsers?.contains(NCMBUser.current().objectId) == true {
                            post.isLiked = true
                        } else {
                            post.isLiked = false
                        }
                        let goodUsers = postObject.object(forKey: "goodUser") as? [String]
                        if goodUsers?.contains(NCMBUser.current().objectId) == true {
                            post.isgood = true
                        } else {
                            post.isgood = false
                        }
                        
                        // いいねの件数
                        if let likes = likeUsers {
                            post.likeCount = likes.count
                        }
                        if let goods = goodUsers {
                            post.goodCount = goods.count
                        }
                        
                        // 配列に加える
                        self.posts.append(post)
                        self.postCountLabel.text = String(posts.count)
                    }
                }
                
                // 投稿のデータが揃ったらTableViewをリロード
                self.UserPagetimelineTableView.reloadData()
            }
        })
     }
        
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        UserPagetimelineTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.loadFollowingUsers()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
    @IBAction func wakaru(){
        self.performSegue(withIdentifier: "toDetail", sender: nil)
    }
    @IBAction func edit(){
        self.performSegue(withIdentifier: "goedit", sender: nil)
    }
    @IBAction func Comments(){
        self.performSegue(withIdentifier: "toUserComments", sender: nil)
    }
    @IBAction func showphoto(){
        self.performSegue(withIdentifier: "toshowphoto2", sender: nil)
    }
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        if segue.identifier == "toDetail"{
            let vc = segue.destination as! SendAnswerViewController
        vc.SecondText = userQuestionTextView.text!
        }else if segue.identifier == "toUserComments"{
//           performSegue(withIdentifier: "toUserComments", sender: nil)
            let commentViewController = segue.destination as! UserCommentsViewController
            commentViewController.postId = selectedPost?.objectId
        }else if segue.identifier == "toshowphoto2"{
            let showphoto = segue.destination as! UserPagePhotoViewController
            showphoto.photoId = selectedPost?.objectId
            print("成功")
        }
    }
    

    @IBAction func showMenu() {
        let alertController = UIAlertController(title: "メニュー", message: "メニューを選択して下さい。", preferredStyle: .actionSheet)
        if UIDevice.current.userInterfaceIdiom == .pad{
                    alertController.popoverPresentationController?.sourceView = self.view
                    let screenSize = UIScreen.main.bounds
                    alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        }

        
        let signOutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
            NCMBUser.logOutInBackground({ (error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: error!.localizedDescription)
                } else {
                    // ログアウト成功
                    let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    // ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                }
            })
        }
        let deleteAction = UIAlertAction(title: "退会", style: .default) { (action) in
            
            let alert = UIAlertController(title: "会員登録の解除", message: "本当に退会しますか？退会した場合、再度このアカウントをご利用頂くことができません。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                // ユーザーのアクティブ状態をfalseに
                if let user = NCMBUser.current() {
                    user.setObject(false, forKey: "active")
                    user.saveInBackground({ (error) in
                        if error != nil {
                            KRProgressHUD.showError(withMessage: error!.localizedDescription)
                        } else {
                            // userのアクティブ状態を変更できたらログイン画面に移動
                            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                         UIApplication.shared.keyWindow?.rootViewController = rootViewController
                            
                            // ログイン状態の保持
                            let ud = UserDefaults.standard
                            ud.set(false, forKey: "isLogin")
                            ud.synchronize()
                        }
                    })
                } else {
                    // userがnilだった場合ログイン画面に移動
                    let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    // ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                }
                
            })
            
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            })
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(signOutAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func loadFollowingInfo() {
        // フォロー中
        let followingQuery = NCMBQuery(className: "Follow")
        followingQuery?.includeKey("user")
        followingQuery?.whereKey("user", equalTo: NCMBUser.current())
        followingQuery?.countObjectsInBackground({ (count, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            } else {
                // 非同期通信後のUIの更新はメインスレッドで
                DispatchQueue.main.async {
                    self.followingCountLabel.text = String(count)
                }
            }
        })
        
        // フォロワー
        let followerQuery = NCMBQuery(className: "Follow")
        followerQuery?.includeKey("following")
        followerQuery?.whereKey("following", equalTo: NCMBUser.current())
        followerQuery?.countObjectsInBackground({ (count, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    // 非同期通信後のUIの更新はメインスレッドで
                    self.followerCountLabel.text = String(count)
                }
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
        query?.whereKey("user", equalTo: NCMBUser.current())
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            } else {
                self.followings = [NCMBUser]()
                for following in result as! [NCMBObject] {
                    self.followings.append(following.object(forKey: "following") as! NCMBUser)
                }
                self.followings.append(NCMBUser.current())
                
                self.loadTimeline()
            }
        })
    }
}
