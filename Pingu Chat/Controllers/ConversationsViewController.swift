//
//  ViewController.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 29/10/20.
//  Copyright © 2020 vladislav vaz. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        //Checking user login using user defaults
        
        /*
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        
        if !isLoggedIn {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        } */
        
        
       
        validateAuth()
        
        
    
    }
    
    //Function to check is user is logged in (firebase)
    
    private func validateAuth() {
               
        if FirebaseAuth.Auth.auth().currentUser == nil {
                          let vc = LoginViewController()
                          let nav = UINavigationController(rootViewController: vc)
                          nav.modalPresentationStyle = .fullScreen
                          present(nav, animated: false)
                      }
               
           }
    
    


}

