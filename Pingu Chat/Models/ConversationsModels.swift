//
//  ConversationsModels.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 04/01/21.
//  Copyright © 2021 vladislav vaz. All rights reserved.
//

import Foundation

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
