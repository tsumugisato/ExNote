//
//  Answer.swift
//  original
//
//  Created by 佐藤紬 on 2021/03/15.
//

import UIKit

class Answer:NSObject {
    var objectId:String
//    var objectId: String
    var user: User
    var imageUrl: String
    var text: String
    var createDate: Date
//    var answers: String
    var question:String

    init(objectId:String, user: User, imageUrl: String, text: String, createDate: Date,question:String) {
        
        self.objectId = objectId
        self.user = user
        self.imageUrl = imageUrl
        self.text = text
        self.createDate = createDate
        self.question = question
    }
}
