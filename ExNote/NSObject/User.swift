//
//  User.swift
//  instasample
//
//  Created by 佐藤紬 on 2021/03/04.
//

import UIKit

class User {
    var objectId:String
    var userName:String
    var displayName:String?
    var introduction:String?
    var major:String?
    var wantNote:String?
    var question:String?

    init(objectId:String,userName:String){
        self.objectId = objectId
        self.userName = userName
//        self.displayName = displayName
//        self.introduction = introduction
//        self.major = major
//        self.wantNote = wantNote
//        self.question = question
    }

}
