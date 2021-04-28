//
//  UserPagePhotoViewController.swift
//  ExNote
//
//  Created by 佐藤紬 on 2021/04/24.
//

import UIKit
import Kingfisher
import NCMB

class UserPagePhotoViewController: UIViewController {
    
    var photoId:String!
    
    
    @IBOutlet var photoimageView:UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        photoimageView = photoId as! UIImageView
//        photoimageView.kf.setImage(with: URL(string: photoId))
        loadTimeline()
    }
    func loadTimeline(){
        let query = NCMBQuery(className:"Post")
        query?.whereKey("objectId",equalTo:photoId)
        query?.findObjectsInBackground({(result,error) in
            if error != nil{
                print(error)
            }else{
                for imageObject in result as! [NCMBObject]{
                    let imageUrl = imageObject.object(forKey: "imageUrl") as! String
                    self.photoimageView.kf.setImage(with:URL(string: imageUrl))
                    print(imageUrl)
                }
            }
        })
        
        
    }
}
