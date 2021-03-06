//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 菅野 英俊 on 2018/07/04.
//  Copyright © 2018年 菅野 英俊. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setPostData(postData: PostData) {
        self.postImageView.image = postData.image

        self.captionLabel.text = "投稿者：\(postData.name!)  \(postData.caption!)"
        
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: postData.date!)
        self.dateLabel.text = dateString
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        // コメントをcommentLabelに格納する
        //// ラベルの初期化
        self.commentLabel.text = ""
        //// コメントの有無をチェック
        if postData.commentUserName.count != 0 {
            // コメントをLabelに追記する。
            for i in 0 ..< postData.commentUserName.count {
                commentLabel.text = commentLabel.text! + postData.commentUserName[i] + " : " + postData.comment[i] + "\n"
            }
        }
    }
    
}






