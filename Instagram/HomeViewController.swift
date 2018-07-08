//
//  HomeViewController.swift
//  Instagram
//
//  Created by 菅野 英俊 on 2018/06/28.
//  Copyright © 2018年 菅野 英俊. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var postArray: [PostData] = []
    var commentArray: [CommentData] = []
    
    // DatabaseのobserveEventの登録状態を表す
    var observing = false
    
    
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // テーブルセルのタップを無効にする
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // テーブル行の高さの概算値を設定しておく
        // 高さ概算値 = 「縦横比1:1のUIImageViewの高さ(=画面幅)」+「いいねボタン、キャプションラベル、その他余白の高さの合計概算(=100pt)」
        tableView.estimatedRowHeight = UIScreen.main.bounds.height + 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            print("オブザーバーのステータス \(self.observing)")
            if self.observing == false {
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded) { (snapshot) in
                    print("DEBUG_PRINT: Postの.childAddedイベントが発生しました。")
                    
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at: 0)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                }
                
                postsRef.observe(.childChanged) { (snapshot) in
                    print("DEBUG_PRINT: Postの.childChangedイベントが発生しました。")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.postArray.remove(at: index)
                        
                        // 削除したところに更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                }
                
                // コメントが追加された時の処理
                let commentRef = Database.database().reference().child(Const.commentDBPath)
                commentRef.observe(.childAdded) { (snapshot) in
                    print("DEBUG_PRINT: Commentの.childAddedイベントが発生しました。")
                    
                    // ログインしている場合は描画処理実行
                    if let uid = Auth.auth().currentUser?.uid {
                        let commentData = CommentData(snapshot: snapshot, myId: uid)
                        
                        if commentData.comment?.count != 0 {
                            // コメントをした投稿の特定
                            let postId = commentData.postId
                            var index: Int = 0
                            for post in self.postArray {
                                print("post.id = \(post.id), postId = \(postId)")
                                if post.id == postId {
                                    index = self.postArray.index(of: post)!
                                    break
                                }
                            }
                            
                            // コメントデータの作成
                            self.postArray[index].commentUserName.append(commentData.commentUserName!)
                            self.postArray[index].comment.append(commentData.comment!)
                            let tableData = self.postArray[index]
                            
                            // 投稿にコメントを記載
                            self.postArray.remove(at: index)
                            self.postArray.insert(tableData, at: index)
                            print("postArrayComment = \(self.postArray[index].comment), postArray = \(self.postArray[index].id)")
                            
                            // TableViewを再表示
                            self.tableView.reloadData()
                        }
                    }
                }
                
                // DatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                observing = true
            }
        }
        else {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                postArray = []
                tableView.reloadData()
                
                // オブザーバーを削除する
                Database.database().reference().removeAllObservers()
                
                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postData: postArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action: #selector(handleLikeButton(sender:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action: #selector(handleCommentButton(sender:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func handleLikeButton( sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.isLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = postData.likes.index(of: likeId)!
                        break
                    }
                }
                postData.likes.remove(at: index)
            }
            else {
                postData.likes.append(uid)
            }
            
            // 更新されたlikesをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)
        }
    }
    
    
    @objc func handleCommentButton( sender: UIButton, forEvent event: UIEvent ) {
        print("DEBUG_PRINT: commentボタンがタップされました。")
        // タップされたインデックスを特定する。
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 選択されたデータを取得する。
        let postData = postArray[indexPath!.row]

        let commentController = self.storyboard?.instantiateViewController(withIdentifier: "Comment") as! CommentViewController
        commentController.postId = postData.id
        self.present(commentController, animated: true, completion: nil)
    }
    

}









