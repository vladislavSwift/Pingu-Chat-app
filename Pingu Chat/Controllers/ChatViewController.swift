//
//  ChatViewController.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 07/11/20.
//  Copyright © 2020 vladislav vaz. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView


struct Message: MessageType {
    
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind

}

extension MessageKind {
    
    var messageKindString: String {
        
        switch self {
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
        
    }
    
}

struct Sender: SenderType {
    
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}


class ChatViewController: MessagesViewController {
    
    
    public static let dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public let otherUserEmail: String
    
    private let conversationId: String?
    
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
       return Sender(photoURL: "",
               senderId: safeEmail,
               displayName: "Pingu")
        
        
       
        
    }
    
    
    init(with email: String, id: String?) {
        
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .link
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
        
        
    }
    
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            
            switch result {
                
            case .success(let messages):
                print("success in getting messages in chatViewController \(messages)")
                guard !messages.isEmpty else {
                    
                    print("Messages are empty")
                    return
                }
                
                self?.messages = messages
                
                DispatchQueue.main.async {
                    
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        
                        self?.messagesCollectionView.scrollToBottom()
                        
                    }
                     
                }
                
               
                
            case .failure(let error):
                print("error occured during listening to messages in chatViewCOntroller \(error)")
                
            }
        })
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        messageInputBar.inputTextView.becomeFirstResponder()
        
        if let conversationId = conversationId {
            
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
    }

}


extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
       
        // if !text.isEmpty
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
        let messageId = createMessageId() else {
            
            return
        }
        
        //Send message
        
        if isNewConversation {
            
            //Create a new Convo in database
            
            let newMessage = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: newMessage, completion: { success in
                
                if success {
                    
                    print("Message sent")
                } else {
                    
                    print("Message sending error")
                }
                
            })
            
            
        } else {
            
            //append to existing conversation data
            
            
            
        }
        
    }
    
    private func createMessageId() -> String? {
        
        //Inputs to create the messageId are date, otherUserEmail, senderEmail, randomInt
        
        
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        //Capital S in self as it is static
        
        let dateString = Self.dateFormatter.string(from: Date())
        
        
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        
        return newIdentifier
    }
    
}



extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        
        if let sender = selfSender {
            
            return sender
            
        }
    
        fatalError("Self Sender is nil, email should be cached")
        
       
        
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
        
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        
        return messages.count
        
    }
    
    
}
