//
//  CommentData.swift
//  Instagram
//
//  Created by 菅野 英俊 on 2018/07/06.
//  Copyright © 2018年 菅野 英俊. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase



class CommentData: NSObject {
    var id: String?
    var comment: String?
    var commentUserName: String?
    var postId: String?
    
    
    
    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: Any]
        
        self.comment = valueDictionary["comment"] as? String
        self.commentUserName = valueDictionary["commentUserName"] as? String
        self.postId = valueDictionary["postId"] as? String
    }

}


