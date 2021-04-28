//
//  EditUserinfoViewController.swift
//  instasample
//
//  Created by 佐藤紬 on 2021/02/23.
//

import UIKit
import NCMB
import NYXImagesKit

class EditUserinfoViewController: UIViewController, UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
//    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var userImageView2:UIImageView!
    @IBOutlet var userNameTextField:UITextField!
    @IBOutlet var userIdTextField:UITextField!
    @IBOutlet var introductionTextView:UITextView!
    @IBOutlet var questionTextView:UITextView!
    @IBOutlet var majorTextField:UITextField!
    @IBOutlet var wantNoteTextField:UITextField!
    @IBOutlet var button:UIButton!
    

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        userImageView?.layer.cornerRadius = userImageView.bounds.width / 2.0
//        userImageView?.layer.masksToBounds = true
        userNameTextField.delegate = self
        userIdTextField.delegate = self
        introductionTextView.delegate = self
        questionTextView.delegate = self
        majorTextField.delegate = self
        wantNoteTextField.delegate = self
        
        introductionTextView.layer.cornerRadius = 10.0
        questionTextView.layer.cornerRadius = 10.0
        button.layer.cornerRadius = 10.0
        
        if let user = NCMBUser.current(){
            userNameTextField.text = user.object(forKey:"displayName") as? String
            userIdTextField.text = user.userName
            introductionTextView.text = user.object(forKey:"introduction") as? String
            majorTextField.text = user.object(forKey: "major") as? String
            //あとで変える
            questionTextView.text = user.object(forKey: "question") as? String
            wantNoteTextField.text = user.object(forKey: "wantNote") as? String
            
        
        let file = NCMBFile.file(withName: NCMBUser.current()?.objectId, data: nil)as! NCMBFile
        file.getDataInBackground{(data,error) in
            if error != nil{
                print(error as Any)
            }else{
                if data != nil{
                    let image = UIImage(data: data!)
                    self.userImageView2.image = image
                }
            }
        }
        }else{
            let storyboard = UIStoryboard(name:"SignIn",bundle:Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    //ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false,forKey: "isLogin")
            ud.synchronize()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        let resizedImage = selectedImage.scale(byFactor: 0.4)
                          
        picker.dismiss(animated: true, completion: nil)
        
        let data = UIImage.pngData(resizedImage!)
        let file = NCMBFile.file(withName: NCMBUser.current()?.objectId, data: data())as! NCMBFile
        //ここでエラーが起こる({[self](error)が元々⇨
        file.saveInBackground({[self](error) in
            if error != nil{
                print(error as Any)
            }else{
//                self.userImageView.image = selectedImage
                self.userImageView2.image = selectedImage
            }
        }) {(progress) in
            print(progress)
        }
      }
        @IBAction func selectedImage(){
        let actionController = UIAlertController(title:"画像の選択",message:"選択してください",preferredStyle: .actionSheet)
            if UIDevice.current.userInterfaceIdiom == .pad{
                        actionController.popoverPresentationController?.sourceView = self.view
                        let screenSize = UIScreen.main.bounds
                        actionController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
            }
        let cameraAction = UIAlertAction(title:"カメラ",style:.default){(action) in
            //カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true{
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            self.present(picker,animated:true,completion:nil)
            }else{
                print("この機種ではカメラが使用できません")
            }
        }
        let albumAction =  UIAlertAction(title:"フォトライブラリ",style:.default){(action) in
            //アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true{
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker,animated:true,completion:nil)
           }else{
            print("この機種ではフォトライブラリが使用できません")
           }
        }
        let cancelAction = UIAlertAction(title:"キャンセル",style:.cancel){(action) in
            actionController.dismiss(animated: true, completion: nil)
        }
        actionController.addAction(cameraAction)
        actionController.addAction(albumAction)
        actionController.addAction(cancelAction)
        self.present(actionController,animated:true, completion: nil)
    }
    @IBAction func closeEditViewController(){
        self.navigationController?.popToRootViewController(animated: true)
               
    }
    @IBAction func saveUberInfo(){
        let user = NCMBUser.current()
        user?.setObject(userNameTextField.text,forKey:"displayName")
        user?.setObject(userIdTextField.text,forKey:"userName")
        user?.setObject(majorTextField.text, forKey: "major")
        user?.setObject(wantNoteTextField.text, forKey: "wantNote")
        user?.setObject(introductionTextView.text, forKey: "introduction")
        //questionだけが違うから変える
        user?.setObject(questionTextView.text,forKey: "question")
        user?.saveInBackground({(error) in
            if error != nil{
                print(error as Any)
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
                
        })
    }
    @objc func keyboardWillHide() {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
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
    
    @objc func dismissKeyboard() {
            self.view.endEditing(true)
        }
}
    

//extension ViewController: UITextFieldDelegate {
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.view.endEditing(true)
//        return false
//    }
//  }
