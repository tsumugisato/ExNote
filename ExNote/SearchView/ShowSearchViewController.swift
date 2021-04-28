//
//  ShowSearchViewController.swift
//  original
//
//  Created by 佐藤紬 on 2021/04/11.
//

import UIKit
import NCMB
import Kingfisher
import KRProgressHUD
import SwiftDate

class ShowSearchViewController: UIViewController,UICollectionViewDataSource{
    
   
    
    
    var posts = [Post]()
    var selectedUser:NCMBUser!
    var userId:NCMBUser!    
    var presentuser:NCMBUser!
    var thisUser:User?
    var users = [NCMBUser]()
    var selectedPost: Post?
    var followings = [NCMBUser]()
    var followingInfo:NCMBObject?
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userDisplayNameLabel: UILabel!
    
    @IBOutlet var userIntroductionTextView: UITextView!
    
    @IBOutlet var userquestionTextView:UITextView!
    
    @IBOutlet var usermajorTextField:UITextField!
    
    @IBOutlet var userwantNote:UITextField!
    
    @IBOutlet var photoCollectionView: UICollectionView!
    
    @IBOutlet var postCountLabel: UILabel!
    
    @IBOutlet var followerCountLabel: UILabel!
    
    @IBOutlet var followingCountLabel: UILabel!
    
    @IBOutlet var collectionViewFlowLayout:UICollectionViewFlowLayout!
    
    @IBOutlet var wakaruu:UIButton!
    
    @IBOutlet var followButton: UIButton!
    
    
    
//    // レイアウト設定
     private let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
//
//     // 1行あたりのアイテム数
     private let itemsPerRow: CGFloat = 3
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollectionView.dataSource = self
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        userIntroductionTextView.layer.cornerRadius = 10.0
        userquestionTextView.layer.cornerRadius = 10.0
        wakaruu.layer.cornerRadius = 10.0
        
        
        let nib = UINib(nibName:"searchCollectionViewCell",bundle:Bundle.main)
        photoCollectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        loadPosts()
        loadFollowingInfo()
        loadFollowingUsers()
//
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 124, height: 124)
        photoCollectionView.collectionViewLayout = layout

        let query = NCMBUser.query()
        print(selectedUser,"AAAA")
        query?.whereKey("objectId", equalTo:selectedUser)
        query?.findObjectsInBackground({ [self](result, error) in
            if error != nil{
                print(error)
            }else{
                if let user = NCMBUser.current() {
                    userDisplayNameLabel.text = selectedUser.object(forKey: "displayName") as? String
                    userIntroductionTextView.text = selectedUser.object(forKey: "introduction") as? String
                    userquestionTextView.text = selectedUser.object(forKey: "question") as! String
                    usermajorTextField.text = selectedUser.object(forKey: "major") as! String
                    userwantNote.text = selectedUser.object(forKey: "wantNote") as! String
                    print(posts,"&&&!")
                print(posts,"eeeee")
                    
                    print(thisUser,"66666")
                    print(selectedUser,"7777")
                
                let file = NCMBFile.file(withName: selectedUser.objectId , data: nil) as! NCMBFile
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
    
//    override func viewWillAppear(_ animated: Bool) {
//
//        loadPosts()
//
//        loadFollowingInfo()
////        setRefreshControl()
//
//
//        let query = NCMBUser.query()
//        print(selectedUser,"AAAA")
//        query?.whereKey("objectId", equalTo:selectedUser)
//        query?.findObjectsInBackground({ [self](result, error) in
//            if error != nil{
//                print(error)
//            }else{
//                if let user = NCMBUser.current() {
//                    userDisplayNameLabel.text = selectedUser.object(forKey: "displayName") as? String
//                    userIntroductionTextView.text = selectedUser.object(forKey: "introduction") as? String
//                    userquestionTextView.text = selectedUser.object(forKey: "question") as! String
//                    usermajorTextField.text = selectedUser.object(forKey: "major") as! String
//                    userwantNote.text = selectedUser.object(forKey: "wantNote") as! String
//                    print(posts,"&&&!")
//                print(posts,"eeeee")
//
//                    print(thisUser,"66666")
//                    print(selectedUser,"7777")
//
//                let file = NCMBFile.file(withName: user.objectId , data: nil) as! NCMBFile
//                file.getDataInBackground { (data, error) in
//                    if error != nil{
//                        print(error)
//
//                    } else {
//                        if data != nil{
//                        let image = UIImage(data: data!)
//                        self.userImageView.image = image
//                        }
//                    }
//                }
//            }
//            }
//        })
//
//    }
    @IBAction func wakaru(){
        self.performSegue(withIdentifier: "toSearchAnswer", sender: nil)
        
    }

    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        if segue.identifier == "toSearchAnswer"{
            let vc = segue.destination as! SendfollowerViewController
            vc.SecondText = userquestionTextView.text
        }else {
            print("成功")
        }
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! searchCollectionViewCell
        let photoImageView = cell.viewWithTag(1) as! UIImageView
        let photoImagePath = posts[indexPath.row].imageUrl
//        let photoImageView = searchCollectionViewCell
            let imageUrl = posts[indexPath.row].imageUrl as! String
        cell.photoImageView.kf.setImage(with: URL(string: imageUrl))
//
//        photoImageView.kf.setImage(with: URL(string: photoImagePath))
        
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal // 横スクロール
//        collectionView.collectionViewLayout = layout
//        let size = collectionView.frame.height
//        layout.itemSize = CGSize(width: size, height: size)
        return cell
    }
    // Screenサイズに応じたセルサイズを返す
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem )
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return sectionInsets
     }
    // セルの行間の設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    func loadFollowingStatus() {
           let query = NCMBQuery(className: "Follow")
           query?.includeKey("user")
           query?.includeKey("following")
           query?.whereKey("user", equalTo: NCMBUser.current())
           
           query?.findObjectsInBackground({ (result, error) in
               if error != nil {
                   KRProgressHUD.showError(withMessage: error!.localizedDescription)
               } else {
                   for following in result as! [NCMBObject] {
                       let user = following.object(forKey: "following") as! NCMBUser
                       
                       // フォロー状態だった場合、ボタンの表示を変更
                       if self.selectedUser.objectId == user.objectId {
                           // 表示変更を高速化するためにメインスレッドで処理
                           DispatchQueue.main.async {
                            self.followButton.setTitle("フォロー解除", for: UIControl.State.normal)
                            self.followButton.setTitleColor(UIColor.red, for: UIControl.State.normal)
//                               self.followButton.borderColor = UIColor.red
                           }
                           
                           // フォロー状態を管理するオブジェクトを保存
                           self.followingInfo = following
                           break
                       }
                   }
               }
           })
       }

    
    func loadPosts() {
        guard let userObject = selectedUser
        else{return}
        let query = NCMBQuery(className: "Post")
        query?.includeKey("user")
        query?.whereKey("user", equalTo: userObject)
        query?.order(byDescending: "creatDate")
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            } else {
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    
                    if user.object(forKey: "active") as? Bool != false {
                    let userModel = User(objectId: user.objectId, userName: user.userName)
               
                
                    userModel.major = user.object(forKey: "major") as? String
                    userModel.wantNote = user.object(forKey: "wantNote") as? String
                    
                    // 投稿の情報を取得
                    let imageUrl = postObject.object(forKey: "imageUrl") as! String
                    let text = postObject.object(forKey: "text") as! String
                    let subject = postObject.object(forKey: "subject") as! String
                    
                    // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                    let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate,subject:subject)
                    
                    // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
//                    let likeUser = postObject.object(forKey: "likeUser") as? [String]
//                    if likeUser?.contains(NCMBUser.current().objectId) == true {
//                        post.isLiked = true
//                    } else {
//                        post.isLiked = false
//                    }
                    // 配列に加える
                    self.posts.append(post)
                }
                }
                self.photoCollectionView.reloadData()
                
                // post数を表示
                self.postCountLabel.text = String(self.posts.count)
            }
        })
    }
    
//    func loadFollowingInfo() {
//        // フォロー中
//        let followingQuery = NCMBQuery(className: "Follow")
//        followingQuery?.includeKey("user")
//        followingQuery?.whereKey("user", equalTo: selectedUser)
//        followingQuery?.countObjectsInBackground({ (count, error) in
//            if error != nil {
//                SVProgressHUD.showError(withStatus: error!.localizedDescription)
//            } else {
//                // 非同期通信後のUIの更新はメインスレッドで
//                DispatchQueue.main.async {
//                    self.followingCountLabel.text = String(count)
//                }
//            }
//        })
//
//        // フォロワー
//        let followerQuery = NCMBQuery(className: "Follow")
//        followerQuery?.includeKey("following")
//        followerQuery?.whereKey("following", equalTo: NCMBUser.current())
//        followerQuery?.countObjectsInBackground({ (count, error) in
//            if error != nil {
//                SVProgressHUD.showError(withStatus: error!.localizedDescription)
//            } else {
//                DispatchQueue.main.async {
//                    // 非同期通信後のUIの更新はメインスレッドで
//                    self.followerCountLabel.text = String(count)
//                }
//            }
//        })
//    }
//
//}
    
    func loadFollowingInfo() {
        
//        let query = NCMBUser.query()
//        query?.whereKey("user", equalTo: selectedUser)
//        query?.findObjectsInBackground({ [self] (result, error) in
//            print(selectedUser,"QQQQ")
//            if error != nil{
//                print(error)
//            }else{
//                presentuser = result?[0] as! NCMBUser
                print(selectedUser)

                
                //フォロー機能せず
                let followingQuery = NCMBQuery(className: "Follow")
                followingQuery?.includeKey("user")
                followingQuery?.whereKey("user", equalTo: selectedUser)
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
                followerQuery?.whereKey("following", equalTo: selectedUser)
                followerQuery?.countObjectsInBackground({ (count, error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage:  error!.localizedDescription)
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
        query?.whereKey("user", equalTo: selectedUser)
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
//
//    @IBAction func follow() {
//            // すでにフォロー状態だった場合、フォロー解除
//            if let info = followingInfo {
//                info.deleteInBackground({ (error) in
//                    if error != nil {
//                        KRProgressHUD.showError(withMessage: error!.localizedDescription)
//                    } else {
//                        DispatchQueue.main.async {
//                            self.followButton.setTitle("フォローする", for: UIControl.State.normal)
//                            self.followButton.setTitleColor(UIColor.blue, for:UIControl.State.normal)
////                            self.followButton.borderColor = UIColor.blue
//                        }
//
//                        // フォロー状態の再読込
//                        self.loadFollowingStatus()
//
//                        // フォロー数の再読込
//                        self.loadFollowingInfo()
//                    }
//                })
//            } else {
//                let displayName = selectedUser.object(forKey: "displayName") as? String
//                let message = displayName! + "をフォローしますか？"
//                let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
//                    let object = NCMBObject(className: "Follow")
//                    if let currentUser = NCMBUser.current() {
//                        object?.setObject(currentUser, forKey: "user")
//                        object?.setObject(self.selectedUser, forKey: "following")
//                        object?.saveInBackground({ (error) in
//                            if error != nil {
//                                KRProgressHUD.showError(withMessage: error!.localizedDescription)
//                            } else {
//                                self.loadFollowingStatus()
//                            }
//                        })
//                    } else {
//                        // currentUserが空(nil)だったらログイン画面へ
//                        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
//                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
//                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
//
//                        // ログイン状態の保持
//                        let ud = UserDefaults.standard
//                        ud.set(false, forKey: "isLogin")
//                        ud.synchronize()
//                    }
//                }
//                let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
//                    alert.dismiss(animated: true, completion: nil)
//                }
//                alert.addAction(okAction)
//                alert.addAction(cancelAction)
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
  }
       
