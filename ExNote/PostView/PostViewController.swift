//
//  PostViewController.swift
//  instasample
//
//  Created by 佐藤紬 on 2021/03/01.
//


import UIKit
//import NYXImagesKit
import NCMB
import UITextView_Placeholder
import KRProgressHUD

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate ,UITextFieldDelegate{
    
    let placeholderImage = UIImage(named: "photo-placeholder")
    
    var resizedImage: UIImage!
    
    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet var postTextView: UITextView!
    
    @IBOutlet var postButton: UIBarButtonItem!
    
    @IBOutlet var subjectTextField:UITextField!
    
    @IBOutlet var chooseButton:UIButton!
    
    @IBOutlet var noteImage:UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        postImageView.image = placeholderImage
        
        postButton.isEnabled = false
        postTextView.placeholder = "解説/詳細/質問を書く"
        postTextView.delegate = self
        subjectTextField.delegate = self
        postImageView.layer.cornerRadius = 10.0
        postTextView.layer.cornerRadius = 10.0
        subjectTextField.layer.cornerRadius = 10.0
        chooseButton.layer.cornerRadius = 10.0
        
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as! UIImage
        
        resizedImage = selectedImage.scale(byFactor: 0.4)
        
        postImageView.image = resizedImage
        
        picker.dismiss(animated: true, completion: nil)
        
        confirmContent()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        confirmContent()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    @IBAction func selectImage() {
        let alertController = UIAlertController(title: "画像選択", message: "シェアする画像を選択して下さい。", preferredStyle: .actionSheet)
        if UIDevice.current.userInterfaceIdiom == .pad{
                    alertController.popoverPresentationController?.sourceView = self.view
                    let screenSize = UIScreen.main.bounds
                    alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
            // カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用出来ません。")
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "フォトライブラリから選択", style: .default) { (action) in
            // アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用出来ません。")
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sharePhoto() {
        KRProgressHUD.show()
        
        // 撮影した画像をデータ化したときに右に90度回転してしまう問題の解消
        UIGraphicsBeginImageContext(resizedImage.size)
        let rect = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
        resizedImage.draw(in: rect)
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let data = resizedImage.jpegData(compressionQuality: 0.1)
        // ここを変更（ファイル名無いので）
        let file = NCMBFile.file(with: data) as! NCMBFile
        file.saveInBackground({ (error) in
            if error != nil {
                KRProgressHUD.dismiss()
                let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
            
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                // 画像アップロードが成功
                let postObject = NCMBObject(className: "Post")
                //もし何も入力されてなかったら
                if self.postTextView.text.utf8CString.count == 0 {
                    print("入力されていません")
                    return
                }
                if self.subjectTextField.text!.utf8CString.count == 0 {
                    print("入力されていません")
                    return
                }
                
                postObject?.setObject(self.postTextView.text!, forKey: "text")
                postObject?.setObject(self.subjectTextField.text!, forKey: "subject")
                postObject?.setObject(NCMBUser.current(), forKey: "user")
                let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/A3RYolrkOGtbzizi/publicFiles/" + file.name
                postObject?.setObject(url, forKey: "imageUrl")
                postObject?.saveInBackground({ (error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage: error!.localizedDescription)
                    } else {
                        KRProgressHUD.dismiss()
                        self.postImageView.image = nil
                        self.postImageView.image = UIImage(named: "photo-placeholder")
                        self.postTextView.text = nil
                        self.subjectTextField.text = nil
                        self.tabBarController?.selectedIndex = 0
                    }
                })
            }
        }) { (progress) in
            print(progress)
        }
    }
    
    func confirmContent() {
        if postTextView.text.utf8CString.count > 0 && postImageView.image != placeholderImage {
            postButton.isEnabled = true
        } else {
            postButton.isEnabled = false
        }
        if subjectTextField.text!.utf8CString.count > 0 && postImageView.image != placeholderImage {
            postButton.isEnabled = true
        } else {
            postButton.isEnabled = false
        }
    }
    
    @IBAction func cancel() {
        if postTextView.isFirstResponder || subjectTextField.isFirstResponder == true {
            postTextView.resignFirstResponder()
            subjectTextField.resignFirstResponder()
        }
        
        let alert = UIAlertController(title: "投稿内容の破棄", message: "入力中の投稿内容を破棄しますか？", preferredStyle: .alert)
      
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.postTextView.text = nil
            self.subjectTextField.text = nil
            self.postImageView.image = UIImage(named: "photo-placeholder")
            self.confirmContent()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
//    @objc func keyboardWillHide() {
//            if self.view.frame.origin.y != 0 {
//                self.view.frame.origin.y = 0
//            }
//    }
//
//    @objc func keyboardWillShow(notification: NSNotification) {
//            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                if self.view.frame.origin.y == 0 {
//                    self.view.frame.origin.y -= keyboardSize.height
//                } else {
//                    let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
//                    self.view.frame.origin.y -= suggestionHeight
//                }
//            }
//        }
//
//    @objc func dismissKeyboard() {
//            self.view.endEditing(true)
//        }
}
    

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}



        
     
