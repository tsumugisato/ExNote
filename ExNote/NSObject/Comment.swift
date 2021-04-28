//
//  Commetnt.swift
//  instasample
//
//  Created by 佐藤紬 on 2021/03/04.
//

import UIKit

class Comment: NSObject {
    var postId:String
    var user:User
    var text:String
    var createDate:Date
    
    init(postId:String,user:User,text:String,createDate:Date){
        self.postId = postId
        self.user = user
        self.text = text
        self.createDate = createDate
    }

}
