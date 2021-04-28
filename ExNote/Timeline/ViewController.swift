//
//  ViewController.swift
//  ExNote
//
//  Created by 佐藤紬 on 2021/04/15.
//

import UIKit
import NCMB
import Kingfisher
import KRProgressHUD
import SwiftDate

class ViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate,TimelineTableViewCellDelegate {
    
    
    var willuser:String!
    var presentuser:NCMBUser!
    var searchBar2:UISearchBar!
    var thisUser:NCMBUser!
    var selectedPost: Post?
    var thisselect:NCMBUser?
    var posts = [Post]()
    var selectedUser :NCMBUser!
    var followings = [NCMBUser]()
    var Users = [NCMBUser]()
    var postUser:User?
    
    
    var blockedUserIdArray = [String]()
//    var Block = [Block]()
    var searchController = UISearchController(searchResultsController: nil)

    
    
    @IBOutlet var timelineTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
        
        let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        timelineTableView.tableFooterView = UIView()
        setSearchBar()
        // 引っ張って更新
        setRefreshControl()
        searchController.delegate = self
        // フォロー中のユーザーを取得する。その後にフォロー中のユーザーの投稿のみ読み込み
        loadFollowingUsers()
        timelineTableView.rowHeight = 630
    
    }
    override func viewWillAppear(_ animated: Bool) {
        loadTimeline(searchText: searchBar2.text)
        setRefreshControl()
        print(NCMBUser.current())
    }
//    override func viewDidAppear(_ animated: Bool) {
//        searchController.isActive = true
//    }
    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "科目/分野/授業名を検索"
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar2 = searchBar
        }
    }
        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.setShowsCancelButton(true, animated: true)
            return true
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            loadTimeline(searchText: nil)
            searchBar.showsCancelButton = false
            searchBar.resignFirstResponder()
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            
            loadTimeline(searchText: searchBar2.text)
        }
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }

//    @IBAction func Comments(){
//        self.performSegue(withIdentifier: "toComments", sender: nil)
//    }
//
//    @IBAction func showfollower(){
//        self.performSegue(withIdentifier: "toshowfollwer", sender: nil)
//    }
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        if segue.identifier == "toshowfollower"{
        
            willuser = selectedPost?.user.objectId
            
            let query = NCMBUser.query()
            query?.whereKey("objectId",equalTo: willuser)
            print(willuser,"eee")
                query?.findObjectsInBackground({ [self] (result, error) in
                  if error != nil{
                    print(error)
                  }else{
                    print(result,"aaaaaa")
                    presentuser = result?[0] as! NCMBUser
                  }
                })
            let followuserViewController = segue.destination as! followUserViewController
            followuserViewController.selectedUser = selectedPost?.user.objectId
            followuserViewController.thisUser = selectedPost?.user
            
            print(willuser,"((((())")
            print(selectedPost?.user.objectId)
            print(selectedPost,"3333")
            print(selectedUser,"44444")
            print(thisUser,"5555")
            
    }else if segue.identifier == "toComments"{
//           performSegue(withIdentifier: "toUserComments", sender: nil)
            let commentViewController = segue.destination as! CommentViewController
            
            commentViewController.postId = selectedPost?.objectId
    }else if segue.identifier == "toshowphoto"{
        let showphoto = segue.destination as! followUserPhotoViewController
        showphoto.photoId = selectedPost?.objectId
    }else{
        print("成功")
    }
}
        

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        thisselect = Users[indexPath.row]
//        print(thisselect)
//        self.performSegue(withIdentifier: "tofollower", sender: nil)
//        // 選択状態の解除
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimelineTableViewCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        
        let user = posts[indexPath.row].user
        cell.userNameLabel.text = user.displayName
        let userImageUrl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/A3RYolrkOGtbzizi/publicFiles/" + user.objectId
        cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"), options: nil, progressBlock: nil, completionHandler: nil)
        
        cell.commentTextView.text = posts[indexPath.row].text
        let imageUrl = posts[indexPath.row].imageUrl
        cell.photoImageView.kf.setImage(with: URL(string: imageUrl))
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
 
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            //横からヒョイって出てくるやつ
        let blockaction = UIContextualAction(style: .normal, title: "ブロック") { (action, view, completionHandler) in
                //ワンクッション置く
            let alert = UIAlertController(title: "注意!!", message: "このユーザーをブロックしますか?", preferredStyle: .alert)
        
            let okaction = UIAlertAction(title: "OK", style: .default) { (action) in
                
                if self.posts[indexPath.row].user.objectId != NCMBUser.current()?.objectId{

                    //ブロッククラスの作成
                    let object = NCMBObject(className: "Block")
                    object?.setObject(self.posts[indexPath.row].user.objectId, forKey: "blockedUser")
                    object?.setObject(NCMBUser.current(), forKey: "user")
                    object?.saveInBackground({ (error) in
                        if error != nil{
                            KRProgressHUD.showError(withMessage: "エラー")
                        }else{
                            KRProgressHUD.dismiss()
                            tableView.deselectRow(at: indexPath, animated: true)
                        
                            self.getBlockUser()
                }
            })
            }else{
                let alert = UIAlertController(title: "注意!!", message: "自分をブロックはできません", preferredStyle: .alert)
             
                let action = UIAlertAction(title: "OK", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)}
                        
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                }
            }
            let cancelaction = UIAlertAction(title: "いいえ", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
                    
                }
                
            alert.addAction(cancelaction)
            alert.addAction(okaction)
            self.present(alert, animated: true, completion: nil)
                
            completionHandler(true)
            }
        //禍々しい色に
        blockaction.backgroundColor = UIColor.red
        
        let configuration = UISwipeActionsConfiguration(actions: [blockaction])
        return configuration
        
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
                        self.loadTimeline(searchText: self.searchBar2.text)
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
                            self.loadTimeline(searchText: self.searchBar2.text)
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
                        self.loadTimeline(searchText: self.searchBar2.text)
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
                            self.loadTimeline(searchText: self.searchBar2.text)
                        }
                    })
                }
            })
        }
    }
//
    func getBlockUser(){
        let query = NCMBQuery(className: "Block")
        
        query?.includeKey("user")
        query?.whereKey("user", equalTo: NCMBUser.current())
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            }else{
                self.blockedUserIdArray.removeAll()
                for blockObject in result as! [NCMBObject] {
                    self.blockedUserIdArray.append(blockObject.object(forKey: "blockedUser") as! String)
                }
            }
        })
        loadTimeline(searchText: searchBar2.text)
    }
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
                            self.loadTimeline(searchText: self.searchBar2.text)
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
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
    func didTapshowfollowerButton(tableViewCell:UITableViewCell,button:UIButton){
        selectedPost = posts[tableViewCell.tag]
        print("これが投稿！", posts[tableViewCell.tag].user.objectId)
        self.performSegue(withIdentifier: "toshowfollower", sender: nil)
    }
    
    func didTapshowphotoButton(tableViewCell:UITableViewCell,button:UIButton){
        selectedPost = posts[tableViewCell.tag]
        self.performSegue(withIdentifier: "toshowphoto", sender: nil)
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
    
    func loadTimeline(searchText :String?) {
        
        let query = NCMBQuery(className: "Post")

        // 降順
//        query?.order(byDescending: "createDate")
        
        // 投稿したユーザーの情報も同時取得
        query?.includeKey("user")
        
        // フォロー中の人 + 自分の投稿だけ持ってくる
        query?.whereKey("user", containedIn: followings)

        if let text = searchText{
            if text == ""{
                query?.order(byDescending: "createDate")
        // オブジェクトの取得
        query?.findObjectsInBackground({ (result, error) in
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
                    }
                }
                
                // 投稿のデータが揃ったらTableViewをリロード
                self.timelineTableView.reloadData()
            }
        })
    }else{
    query?.whereKey("subject",equalTo:text)
    print(text)
    }
}
        query?.order(byDescending: "createDate")
// オブジェクトの取得
query?.findObjectsInBackground({ (result, error) in
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
                if self.blockedUserIdArray.firstIndex(of: post.user.objectId) == nil{
                self.posts.append(post)
                    print(self.posts)
            }
        }
        
        // 投稿のデータが揃ったらTableViewをリロード
        self.timelineTableView.reloadData()
      }
    }
     })
    }
        
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        timelineTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.loadFollowingUsers()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
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
                
                self.loadTimeline(searchText: self.searchBar2.text)
            }
        })
    }
    
}
