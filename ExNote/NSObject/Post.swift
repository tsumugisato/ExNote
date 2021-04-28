//
//  Post.swift
//  instasample
//
//  Created by 佐藤紬 on 2021/03/04.
//
//
import UIKit

class Post {
    var objectId: String
    var user: User
    var imageUrl: String
    var text: String
    var createDate: Date
    var isLiked: Bool?
    var isgood:Bool?
    var comments: [Comment]?
    var likeCount: Int = 0
    var goodCount: Int = 0
    var subject:String

    init(objectId: String, user: User, imageUrl: String, text: String, createDate: Date,subject:String) {
        self.objectId = objectId
        self.user = user
        self.imageUrl = imageUrl
        self.text = text
        self.createDate = createDate
        self.subject = subject
        
    }
}
