//
//  followerphotoViewController.swift
//  ExNote
//
//  Created by 佐藤紬 on 2021/04/24.
//

import UIKit
import Kingfisher
import NCMB

class followerphotoViewController: UIViewController, UIScrollViewDelegate {
    
    var photoId:String!
    
    
    @IBOutlet var photoimageView:UIImageView!
    @IBOutlet var photoImageScrollView:UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        photoimageView = photoId as! UIImageView
//        photoimageView.kf.setImage(with: URL(string: photoId))
        photoImageScrollView.minimumZoomScale = 1.0
        photoImageScrollView.maximumZoomScale = 4.0
        photoImageScrollView.delegate = self
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
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
       return photoimageView
    }
}

