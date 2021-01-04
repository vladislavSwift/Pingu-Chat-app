//
//  ChatModels.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 04/01/21.
//  Copyright © 2021 vladislav vaz. All rights reserved.
//

import Foundation
import CoreLocation
import MessageKit

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


struct Media: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Location: LocationItem {
    
    var location: CLLocation
    
    var size: CGSize
    
}
