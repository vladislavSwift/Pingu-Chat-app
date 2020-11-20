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


struct Conversation {
    
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let message: String
    let isRead: Bool
}




class ConversationsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversation = [Conversation]()
    
    private let tableView : UITableView = {
        
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
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
        
        startListeningForConversation()
        
    }
    
    private func startListeningForConversation() {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            
            return
        }
        
        print("starting conversation fetch......")
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: {[weak self] result in
            
            switch result {
                
            case .success(let conversations):
                
                print("successfully got conversation models......")
                
                guard !conversations.isEmpty else {
                    
                    return
                }
                
                self?.conversation = conversations
                
                DispatchQueue.main.async {
                    
                    self?.tableView.reloadData()
                    
                    print("we are now reloading table with the recieved conversations......")
                }
                
            case .failure(let error):
                print("fatal error occurred while getting messages \(error)")
                
            }
            
            
        })
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
        
        vc.completion = { [weak self] result in
            self?.createNewConservation(result: result)
            
        }
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
        
    }
    
    private func createNewConservation(result: [String: String]) {
        
        guard let name = result["name"],
            let email = result["email"] else {
            
            return
        }
        
        let vc = ChatViewController(with: email, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
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
        return conversation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let model = conversation[indexPath.row]
    
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        
        cell.configure(with: model)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversation[indexPath.row]
        
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120
    }
    
}

