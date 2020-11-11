//
//  ChatViewController.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 07/11/20.
//  Copyright © 2020 vladislav vaz. All rights reserved.
//

import UIKit
import MessageKit


struct Message: MessageType {
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind

}


struct Sender: SenderType {
    
    var photoURL: String
    var senderId: String
    var displayName: String
}


class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    
    private let selfSender = Sender(photoURL: "", senderId: "1", displayName: "Pingu Smith")

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .link
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello world Message")))
        
        messages.append(Message(sender: selfSender,
        messageId: "1",
        sentDate: Date(),
        kind: .text("How are you message?. Hello world Message Hello world MessageHello world MessageHello world MessageHello world MessageHello world MessageHello world MessageHello world MessageHello world Message")))
        
    }

}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
    
        return selfSender
        
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
        
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        
        return messages.count
        
    }
    
    
}
