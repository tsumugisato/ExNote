//
//  SigninViewController.swift
//  instasample
//
//  Created by 佐藤紬 on 2021/02/20.
//

import UIKit
import NCMB

class SigninViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var userIdTextField:UITextField!
    @IBOutlet var passwordTextField:UITextField!
    @IBOutlet var signinButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdTextField.delegate = self
        passwordTextField.delegate = self
        signinButton.layer.cornerRadius = 10.0
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func signIn(){
        if (userIdTextField.text?.utf8CString.count)!>0 &&
            (passwordTextField.text?.utf8CString.count)!>0 {
            NCMBUser.logInWithUsername(inBackground:userIdTextField.text!,password:passwordTextField.text!){(user,error) in
                if error != nil{
                    print(error as Any)
                }else{
                    let storyboard = UIStoryboard(name:"Main",bundle:Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")
                    UIApplication.shared.windows.first{$0.isKeyWindow}!.rootViewController = rootViewController
                    //
                    let ud = UserDefaults.standard
                    ud.set(true,forKey: "isLogin")
                    ud.synchronize()
                }
                }
        }
        
    }
    @IBAction func forgetPassword(){
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
