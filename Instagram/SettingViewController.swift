//
//  SettingViewController.swift
//  Instagram
//
//  Created by 菅野 英俊 on 2018/06/28.
//  Copyright © 2018年 菅野 英俊. All rights reserved.
//

import UIKit
import ESTabBarController
import Firebase
import FirebaseAuth

class SettingViewController: UIViewController {

    @IBOutlet weak var displayNameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        let user = Auth.auth().currentUser
        if let user = user {
            displayNameTextField.text = user.displayName
        }
    }
    
    
    @IBAction func handleChangeButton(_ sender: UIButton) {
    }
    
    @IBAction func handleLogoutButton(_ sender: UIButton) {
    }
    


}












