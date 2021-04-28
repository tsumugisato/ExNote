//
//  CollectionViewController.swift
//  ExNote
//
//  Created by 佐藤紬 on 2021/04/27.
//

import UIKit
import NCMB
import KRProgressHUD
import SwiftDate

class CollectionViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,CollectionTableViewCellDelegate {

    var noteArray = [NCMBObject]()
//    var answers = [Answer]()
    var answers = [NCMBObject]()

    var followings = [NCMBUser]()
    
    var questioncell = [String]()
    
    var objectIdcell = [String]()
    
    var usercell = [NCMBUser]()
    
    var imagecell = [String]()
    
    var textcell = [String]()
    
    var toSecondPic:UIImage?
    var toSecondName:String?
    var toSecondquestion:String?
    var toSecondanswer:String?

    @IBOutlet var noteTableView:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        noteTableView.dataSource = self
        noteTableView.delegate = self

//        noteTableView.tableFooterView = UIView()

        let nib = UINib(nibName: "CollectionTableViewCell", bundle: Bundle.main)
        noteTableView.register(nib, forCellReuseIdentifier: "Cell2")
        setRefreshControl()
//        loadData()
        loadanswer()
        print("ddd")
     }
    override func viewWillAppear(_ animated: Bool) {
        print("aaaa")
//        loadData()
        loadanswer()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            print("bbbbbb")
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! CollectionTableViewCell
            
            cell.delegete = self
            cell.tag = indexPath.row
            
        let users = answers[indexPath.row].object(forKey: "user") as! NCMBUser
        cell.userName.text = users.object(forKey: "displayName") as! String
            print("iiiii")
        let questionuser =
        cell.questionname.text = answers[indexPath.row].object(forKey: "question") as! String
        
            let userImageUrl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/A3RYolrkOGtbzizi/publicFiles/" + users.objectId
            cell.userImage.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"), options: nil, progressBlock: nil, completionHandler: nil)
        let file = NCMBFile.file(withName: users.objectId, data: nil) as! NCMBFile
//        file.getDataInBackground { (data, error) in
//            if error != nil {
//                let alert = UIAlertController(title: "画像取得エラー", message: error!.localizedDescription, preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
//
//                })
//                alert.addAction(okAction)
//                self.present(alert, animated: true, completion: nil)
//            } else {
//                if data != nil {
//                    let image = UIImage(data: data!)
//                    cell.userImage.image = image
//                }
//            }
//        }
//    } else {
//        // NCMBUser.current()がnilだったとき
//        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
//        let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
//     UIApplication.shared.keyWindow?.rootViewController = rootViewController
//
//        // ログイン状態の保持
//        let ud = UserDefaults.standard
//        ud.set(false, forKey: "isLogin")
//        ud.synchronize()
        cell.timestamp.text = answers[indexPath.row].createDate.toString()
        return cell
    }
    //押した後に黒い帯が表示される
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        self.performSegue(withIdentifier: "toSecond", sender: nil)
        //押した後に黒い帯が非表示になる
        noteTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //次の画面の取得（detail)
        if segue.identifier == "toSecond"{
            let tosecond = segue.destination as! SecondCollectionViewController
            //何が選ばれているかを取得できる
            let selectedIndex = noteTableView.indexPathForSelectedRow!
            tosecond.selectednote = (answers[selectedIndex.row] as NCMBObject)
            print("!!!",answers[selectedIndex.row] as NCMBObject)
//            tosecond.selectednote = (imagecell[selectedIndex.row] as! NCMBObject)

        }
    }
    
//    func loadData(){
//        let query = NCMBQuery(className:"answer")
//        query?.findObjectsInBackground{(result,error) in
//            if error != nil{
//                print(error!)
//            }else{
//                self.noteArray = result as! [NCMBObject]
//                print(self.noteArray)
//                self.noteTableView?.reloadData()
//            }
//      }
//        print("eeee")
//    }
    
    
    
    func loadanswer() {
    let query = NCMBQuery(className: "answer")
        


    // 降順
    query?.order(byDescending: "createDate")

    // 投稿したユーザーの情報も同時取得
    query?.includeKey("user")

    // フォロー中の人 + 自分の投稿だけ持ってくる

    // オブジェクトの取得
        query?.findObjectsInBackground({ [self] (result, error) in
        if error != nil {
            KRProgressHUD.showError(withMessage: error!.localizedDescription)
        } else {
            // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
            self.answers = [NCMBObject]()

            for answerObject in result as! [NCMBObject] {
                // ユーザー情報をUserクラスにセット
                let user = answerObject.object(forKey: "user") as! NCMBUser

                // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                if user.object(forKey: "active") as? Bool != false {
                    // 投稿したユーザーの情報をUserモデルにまとめる
//                    let userModel = User(objectId: user.objectId, userName: user.userName, displayname: user.displ, introduction: , major: <#T##String#>, wantNote: <#T##String#>, question: <#T##String#>)
//                    userModel.displayName = user.object(forKey: "displayName") as? String

                    // 投稿の情報を取得
//                    let imageUrl = answerObject.object(forKey: "imageURL") as! String
//                    let objectId = answerObject.object(forKey: "objectId") as! String
//                    let question = answerObject.object(forKey:"question") as! String
//                    let user = answerObject.object(forKey:"user") as! NCMBUser
//                    let text = answerObject.object(forKey: "text") as! String
//                    let imageUrl = answerObject.object(forKey: "imageUrl") as! String
                    print("sssssssssss-------")
//                    // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
//                    let answer = Answer(questionId: answerObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: answerObject.createDate,question:question)

                    // 配列に加える
//                    self.questioncell.append(question)
//                    self.objectIdcell.append(objectId)
//                    self.usercell.append(user)
//                    self.imagecell.append(imageUrl)
//                    self.textcell.append(text)
                    self.answers.append(answerObject)
                    print(answerObject)
                }
            }

            // 投稿のデータが揃ったらTableViewをリロード
            self.noteTableView.reloadData()
            
        }
    })
        
}
        func setRefreshControl() {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
            noteTableView.addSubview(refreshControl)
        }

        @objc func reloadTimeline(refreshControl: UIRefreshControl) {
            refreshControl.beginRefreshing()
            self.loadanswer()
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
                self.loadanswer()
            }
        })
    }
}
