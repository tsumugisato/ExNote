import UIKit
import NCMB
import KRProgressHUD
import SwiftDate
import Kingfisher

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,SearchTableViewCellDelegate {

    var users = [NCMBUser]()
    var thisUser:NCMBUser!
    var selectedUser:NCMBUser!
    var followingUserIds = [String]()
    
    var searchBar: UISearchBar!
    var selectedPost:Post?
    var willuser:String!
    var presentuser:NCMBUser!
    var posts = [Post]()
    
    @IBOutlet var searchTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setSearchBar()

        searchTableView.dataSource = self
        searchTableView.delegate = self

        // カスタムセルの登録
        let nib = UINib(nibName: "SearchTableViewCell", bundle: Bundle.main)
        searchTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        searchTableView.rowHeight = 60
        loadUsers(searchText: nil)
        

       
    }

    override func viewWillAppear(_ animated: Bool) {
//        loadUsers(searchText: nil)
        print(users)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUser"{
            
//            willuser = selectedPost?.user.objectId
//            print(willuser,"yyyy")
//            let query = NCMBUser.query()
//            query?.whereKey("objectId",equalTo: willuser)
//            print(willuser,"eee")
//                query?.findObjectsInBackground({ [self] (result, error) in
//                  if error != nil{
//                    print(error)
//                  }else{
//                    print(result,"jjjjj")
//                    presentuser = result?[0] as! NCMBUser
//                  }
//                })
            let seledctedIndex = searchTableView.indexPathForSelectedRow!
            let showsearchViewController = segue.destination as! ShowSearchViewController
            showsearchViewController.thisUser = selectedPost?.user
            showsearchViewController.selectedUser = users[seledctedIndex.row]
        }else{
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toUser", sender: nil)
        // 選択状態の解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let showUserViewController = segue.destination as! ShowUserViewController
//        let selectedIndex = searchUserTableView.indexPathForSelectedRow!
//        showUserViewController.selectedUser = users[selectedIndex.row]
//    }

    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "ユーザー名を検索"
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
    }
    //テンプレ!!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //テンプレ!!
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText: nil)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText: searchBar.text)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SearchTableViewCell

        let userImageUrl = "https:/mbaas.api.nifcloud.com/2013-09-01/applications/A3RYolrkOGtbzizi/publicFiles/" + users[indexPath.row].objectId
        print(users[indexPath.row].objectId,"!!!!!!!")
        cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"), options: nil, progressBlock: nil, completionHandler: nil)
        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
        cell.userImageView.layer.masksToBounds = true

        cell.userNameLabel.text = users[indexPath.row].object(forKey: "displayName") as? String
        print(users)
        // Followボタンを機能させる
        cell.tag = indexPath.row
        cell.delegate = self

        if followingUserIds.contains(users[indexPath.row].objectId) == true {
            cell.followButton.isHidden = true
        } else {
            cell.followButton.isHidden = false
        }

        return cell
    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "toUser", sender: nil)
//        // 選択状態の解除
//        tableView.deselectRow(at: indexPath, animated: true)
//    }

    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton) {
        let displayName = users[tableViewCell.tag].object(forKey: "displayName") as? String
        let message = displayName! + "をフォローしますか？"
        let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.follow(selectedUser: self.users[tableViewCell.tag])
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    func follow(selectedUser: NCMBUser) {
        let object = NCMBObject(className: "Follow")
        if let currentUser = NCMBUser.current() {
            object?.setObject(currentUser, forKey: "user")
            object?.setObject(selectedUser, forKey: "following")
            object?.saveInBackground({ (error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage:error!.localizedDescription)
                } else {
                    self.loadUsers(searchText: nil)
                }
            })
        } else {
            // currentUserが空(nil)だったらログイン画面へ
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController

            // ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
    }

    func loadUsers(searchText: String?) {
        let query = NCMBUser.query()
        
        query?.whereKey("objectId", notEqualTo: NCMBUser.current()?.objectId)
        print(NCMBUser.current()?.objectId)

        // 退会済みアカウントを除外
        query?.whereKey("active", notEqualTo: false)

        // 検索ワードがある場合
        if let text = searchText {
            print(text)
            query?.whereKey("displayName", equalTo: text)
        }

        // 新着ユーザー200人だけ拾う
        query?.limit = 200
        query?.order(byDescending: "createDate")

        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            } else {
                // 取得した新着50件のユーザーを格納
                self.users = result as! [NCMBUser]
                print(result)
                self.loadFollowingUserIds()
            }
        })
    }

    func loadFollowingUserIds() {
        let query = NCMBQuery(className: "Follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user", equalTo: NCMBUser.current())

        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            } else {
                self.followingUserIds = [String]()
                for following in result as! [NCMBObject] {
                    let user = following.object(forKey: "following") as! NCMBUser
                    self.followingUserIds.append(user.objectId)
                }

                self.searchTableView.reloadData()
            }
        })
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    
}


