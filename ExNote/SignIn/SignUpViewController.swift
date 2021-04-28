//
//  SignUpViewController.swift
//  instasample
//
//  Created by 佐藤紬 on 2021/02/18.
//

import UIKit
import NCMB

class SignUpViewController: UIViewController,UITextFieldDelegate{
    
    @IBOutlet var userIdTextField:UITextField!
    @IBOutlet var emailTextField:UITextField!
    @IBOutlet var passwordTextField:UITextField!
    @IBOutlet var confirmTextField:UITextField!
    @IBOutlet var signupButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
        signupButton.layer.cornerRadius = 10.0

        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func signUp(){
        let user = NCMBUser()
        
        if (userIdTextField.text?.utf8CString.count)! < 4 {
            print("文字数が足りません")
            return
        }
        user.userName = userIdTextField.text!
        user.mailAddress = emailTextField.text!
        
        if passwordTextField.text == confirmTextField.text{
            user.password = passwordTextField.text!
        }else{
            print("パスワードの不一致")
        }
        user.signUpInBackground{(error) in
            if error != nil{
                //エラーがあった場合
                print(error as Any)
            }else{
               //登録成功
                let storyboard = UIStoryboard(name:"Main",bundle:Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier:"RootTabBarController")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                
                let ud = UserDefaults.standard
                ud.set(true,forKey: "isLogin")
                ud.synchronize()
            }
        }
    }
}
