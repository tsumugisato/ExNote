//
//  Question.swift
//  original
//
//  Created by 佐藤紬 on 2021/03/15.
//

import UIKit

class Question: NSObject {
    var objectId:String
    var user:User
    var text:String
    var createDate:Date
    
    init(objectId:String,user:User,text:String,createDate:Date){
        self.objectId = objectId
        self.user = user
        self.text = text
        self.createDate = createDate
    }

}
