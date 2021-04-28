//
//  PasswordViewController.swift
//  original
//
//  Created by 佐藤紬 on 2021/04/07.
//


import UIKit
import NCMB

class PasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var passwordTextField : UITextField!
    @IBOutlet var sendButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.delegate = self
        sendButton.layer.cornerRadius = 10.0

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func resetPassward() {
        let result = NCMBUser.requestPasswordResetForEmail(inBackground: passwordTextField.text) { (error) in
         if error != nil {
          print("error")
         }else{
          print("success")
         }
        }
      }

}
