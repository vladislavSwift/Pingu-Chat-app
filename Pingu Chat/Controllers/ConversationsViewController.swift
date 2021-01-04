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


/// Controller to show the list of all conversations

final class ConversationsViewController: UIViewController {
    
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
    
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapComposeButton))
        
        
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        
        setupTableView()
        
        startListeningForConversation()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.startListeningForConversation()
            
            
        })
        
    }
    
    private func startListeningForConversation() {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            
            return
        }
        
        if let observer = loginObserver {
            
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("starting conversation fetch......")
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: {[weak self] result in
            
            switch result {
                
            case .success(let conversations):
                
                print("successfully got conversation models......")
                
                guard !conversations.isEmpty else {
                    
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                
               self?.noConversationsLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.conversation = conversations
                
                DispatchQueue.main.async {
                    
                    self?.tableView.reloadData()
                    
                    print("we are now reloading table with the recieved conversations......")
                }
                
            case .failure(let error):
                
                print("fatal error occurred while getting messages \(error)")
                
                self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                
            }
            
            
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        noConversationsLabel.frame = CGRect(x: 10, y: (view.height-100)/2, width: view.width-20, height: 100)
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
            
            guard let strongSelf = self else {
                
                return
            }
            
            let currentConversations = strongSelf.conversation
            
            if let targetConversation = currentConversations.first(where: {
                
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
                
            }) {
                
                let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
                
                
            } else {
                
                strongSelf.createNewConservation(result: result)
                
                
            }
            
            
            
        }
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
        
    }
    
    private func createNewConservation(result: SearchResult) {
        
        let name = result.name
        let email = DatabaseManager.safeEmail(emailAddress: result.email)
        
        //check in database if conversation with these two users exists
        //if it does, reuse conversation id
        //otherwise use existing code
        
        
        DatabaseManager.shared.conversationExists(with: email, completion: { [weak self] result in
            
            guard let strongSelf = self else {
                
                return
            }
            
            switch result {
                
            case .success(let conversationId):
                
                let vc = ChatViewController(with: email, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
                
            case .failure(_):
                
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            
        })
        
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
        
        openConversation(model)
    }
    
    func openConversation(_ model: Conversation) {
        
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //begin deleting of conversations
            
            let conversationId = conversation[indexPath.row].id
    
            tableView.beginUpdates()
            
            self.conversation.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            
            DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { success in
                
                if !success {
                    
                    
//                    self?.conversation.remove(at: indexPath.row)
//
//                    tableView.deleteRows(at: [indexPath], with: .left)
                    
                    
                    // add model and row back and show  error alert
                    
                }
                
                
            })
            
            
            tableView.endUpdates()
            
            
        }
        
    }
    
    
    
}

