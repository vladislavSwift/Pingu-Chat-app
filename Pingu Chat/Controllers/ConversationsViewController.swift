//
//  ViewController.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 29/10/20.
//  Copyright © 2020 vladislav vaz. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView : UITableView = {
        
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
        
    }()
    
    private let noConversationsLabel: UILabel = {
        
        let label = UILabel()
        label.text = "No Conversations Found!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        
        setupTableView()
        
        fetchConversations()
        
        
      
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
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
    
    //Compose button Function
    
    @objc private func didTapComposeButton() {
        
        let vc = NewConversationViewController()
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
        
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
    
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    private func fetchConversations() {
        
        tableView.isHidden = false
        
    }
    


}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello World"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController()
        vc.title = "Pingu"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}

