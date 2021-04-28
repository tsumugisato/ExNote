//
//  SendfollowerViewController.swift
//  original
//
//  Created by 佐藤紬 on 2021/04/02.
//

import UIKit
import NCMB
import KRProgressHUD

class SendfollowerViewController: UIViewController,UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var SecondText = String()
    
    var questionArray = [NCMBObject]()
    
    
    let placeholderImage = UIImage(named: "photo-placeholder")
    
    var resizedImage:UIImage!
    
    @IBOutlet var questionTextView:UITextView!
    
    @IBOutlet var answerimageView:UIImageView!
    
    @IBOutlet var answerTextView:UITextView!
    
    @IBOutlet var sendButton:UIButton!
    
    @IBOutlet var chooseImage:UIButton!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ここにquestionViewのことを付け足す
        
        questionTextView.text = SecondText
        answerimageView.image = placeholderImage
        
        sendButton?.isEnabled = false
        answerTextView.placeholder = "解説/詳細説明"
        answerTextView.delegate = self
        questionTextView.layer.cornerRadius = 10.0
        answerTextView.layer.cornerRadius = 10.0
        sendButton.layer.cornerRadius = 10.0
        chooseImage.layer.cornerRadius = 10.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        
    }
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as! UIImage
        
        resizedImage = selectedImage.scale(byFactor: 0.4)
        
        answerimageView.image = resizedImage
        
        picker.dismiss(animated: true, completion: nil)
        
        confirmContent()
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
    @IBAction func sendPhoto() {
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
                let answerObject = NCMBObject(className: "answer")
                //もし何も入力されてなかったら
                if self.answerTextView.text.utf8CString.count == 0 {
                    print("入力されていません")
                    return
                }
                answerObject?.setObject(self.answerTextView.text!, forKey: "text")
                answerObject?.setObject(NCMBUser.current(), forKey: "user")
                let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/A3RYolrkOGtbzizi/publicFiles/" + file.name
                answerObject?.setObject(url, forKey: "imageUrl")
                answerObject?.setObject(self.questionTextView.text!, forKey: "question")
                answerObject?.saveInBackground({ (error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage: error!.localizedDescription)
                    } else {
                        KRProgressHUD.dismiss()
                        self.answerimageView.image = nil
                        self.answerimageView.image = UIImage(named: "photo-placeholder")
                        self.answerTextView.text = nil
                        self.tabBarController?.selectedIndex = 0
                   }
              })
           }
         })
    }
        func confirmContent() {
            if answerTextView.text.utf8CString.count > 0 && answerimageView.image != placeholderImage {
                sendButton.isEnabled = true
            } else {
                sendButton?.isEnabled = false
            }
        }
    @IBAction func cancel() {
        if answerTextView.isFirstResponder == true {
            answerTextView.resignFirstResponder()
        }
        let alert = UIAlertController(title: "投稿内容の破棄", message: "入力中の投稿内容を破棄しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.answerTextView.text = nil
            self.answerimageView.image = UIImage(named: "photo-placeholder")
            self.confirmContent()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
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
