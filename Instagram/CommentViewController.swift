//
//  CommentViewController.swift
//  Instagram
//
//  Created by 菅野 英俊 on 2018/07/05.
//  Copyright © 2018年 菅野 英俊. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class CommentViewController: UIViewController {

    @IBOutlet weak var commentBox: UITextView!
    
    var postId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    @IBAction func commentSend(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        // コメントの取得
        if let comment = commentBox.text {
            // ユーザーIDの取得
            if let userName = Auth.auth().currentUser?.displayName {
                print("displayName : \(userName)")
                // データの格納
                let postRef = Database.database().reference().child(Const.commentDBPath)
                let postDic = ["postId": postId,"commentUserName": userName, "comment": comment]
                postRef.childByAutoId().setValue(postDic)
                
                SVProgressHUD.showSuccess(withStatus: "コメントを投稿しました。")
                self.dismiss(animated: true, completion: nil)
            }
            else {
                SVProgressHUD.showError(withStatus: "コメントの投稿に失敗しました。")
            }
        }
        
    }
    
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
