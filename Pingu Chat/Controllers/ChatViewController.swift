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
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation

final class ChatViewController: MessagesViewController {
    
    private var senderPhotoUrl: URL?
    private var otherUserPhotoUrl: URL?
    
    
    public static let dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public let otherUserEmail: String
    
    private var conversationId: String?
    
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
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        
        setupInputButton()
        
    }
    
    
    private func setupInputButton() {
        
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal) // add - if dont want -  link
        button.onTouchUpInside { [weak self] _ in
            
            self?.presentInputActionSheet()
        }
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        
    }
    
    
    private func presentInputActionSheet() {
        
        let actionSheet = UIAlertController(title: "Add Attachment", message: "Choose your media of choice", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            
            self?.presentPhotoInputActionSheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self]  _ in
            
            self?.presentVideoInputActionSheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Contact", style: .default, handler: { _ in
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: {  _ in
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self] _ in
            
            self?.presentLocationPicker()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
        
    }
    
    //Action sheet for location messages
    
    private func presentLocationPicker() {
        
       let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick a Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { [weak self] selectedCoordinates in
            
            guard let strongSelf = self else {
                
                return
            }
            
            guard let messageId = strongSelf.createMessageId(),
                let conversationId = strongSelf.conversationId,
                let name = strongSelf.title,
                let selfSender = strongSelf.selfSender else {
                
                return
            }
            
            
            let longitude: Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            
            print("The selected long:\(longitude) | lat:\(latitude)")
            
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                 size: .zero)
            
            let newMessage = Message(sender: selfSender,
                                     messageId: messageId,
                                     sentDate: Date(),
                                     kind: .location(location))
            
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: newMessage, completion: { success in
                
                
                if success {
                    
                    print("Sent location successfully to other conversation")
                } else {
                    
                    print("error while sending location to other conversation")
                }
                
                
            })
            
        }
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    //Action sheet for photo messages
    
    private func presentPhotoInputActionSheet() {
        
        let actionSheet = UIAlertController(title: "Attach a photo", message: "Choose photo from?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
           
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self]  _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    //Action sheet for video messages
    
    
    private func presentVideoInputActionSheet() {
        
        let actionSheet = UIAlertController(title: "Attach a Video", message: "Choose Video from?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
           
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self]  _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
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

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let messageId = createMessageId(),
            let conversationId = conversationId,
            let name = self.title,
        let selfSender = selfSender else {
            
            return
        }
        
        
        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
            
            
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "") + ".png"
            
            //Upload the image
            
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                
                guard let strongSelf = self else {
                    
                    return
                }
                
                switch result {
                    
                case .success(let urlString):
                    //Send image to user
                    
                    print("uploading image message data from chatViewController with url \(urlString)")
                    
                    
                    guard let url = URL(string: urlString),
                        let placeholder = UIImage(systemName: "photo") else {
                            
                            return
                    }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let newMessage = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: newMessage, completion: {[weak self] success in
                        
                        
                        if success {
                            
                            print("Sent photo successfully to other conversation")
                            
                            self?.messageInputBar.inputTextView.text = ""
                        } else {
                            
                            print("error while sending photo to other conversation")
                        }
                        
                        
                    })
                    
                    
                    
                    
                case .failure(let error):
                    
                    print("Error while uploading the image file to conversation occured \(error)")
                    
                }
                
            })
            
            
            // if its video message than
            
        } else if let videoUrl = info[.mediaURL] as? URL {
            
            let fileName = "video_message_" + messageId.replacingOccurrences(of: " ", with: "") + ".mov"
            
            //Upload Video
            
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self] result in
                
                guard let strongSelf = self else {
                    
                    return
                }
                
                switch result {
                    
                case .success(let urlString):
                    //Send video to user
                    
                    print("uploading video message url from chatViewController with url \(urlString)")
                    
                    
                    guard let url = URL(string: urlString),
                        let placeholder = UIImage(systemName: "photo") else {
                            
                            return
                    }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let newMessage = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .video(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: newMessage, completion: { success in
                        
                        
                        if success {
                            
                            print("Sent video url successfully to other conversation")
                        } else {
                            
                            print("error while sending video url to other conversation")
                        }
                        
                        
                    })
                    
                    
                    
                    
                case .failure(let error):
                    
                    print("Error while uploading the video file to conversation occured \(error)")
                    
                }
                
            })
            
            
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
        
        messageInputBar.inputTextView.text = nil
        
        print("sending: \(text)")
        
        
        
        

        
         let newMessage = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        
        //Send message
        
        if isNewConversation {
            
            //Create a new Convo in database
            
           
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: newMessage, completion: { [weak self] success in
                
                if success {
                    
                    print("Message sent")
                    
                    self?.messageInputBar.inputTextView.text = nil
                    
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(newMessage.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                    
                    
                    
                    
                } else {
                    
                    print("Message sending error")
                }
                
            })
            
            
        } else {
            
            
            guard let conversationId = conversationId,
                let name = self.title else {
                return
            }
            
            //append to existing conversation data
            
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: newMessage, completion: { [weak self] success in
                
                if success {
                    
                    print("message sent to append to  existing convo")
                    self?.messageInputBar.inputTextView.text = nil
                } else {
                    
                    print("Message failed to send and append to existing convo")
                }
                
            })
            
            
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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        guard let message = message as? Message else {
            
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            
            break
        }
        
    }
    
    // Changing the text sent background
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            
            //This sender is us or message we have sent
            
            return .link
        }
        
        return .secondarySystemBackground
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId {
            // show sender Image
            
            if let currentUserImageURL = self.senderPhotoUrl {
                
                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
            } else {
                
                // path in the database
                // images/safeemail_profile_picture.png
                
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    
                    return
                }
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                let path = "images/\(safeEmail)_profile_picture.png"
                
                // fetch url
                
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    
                    switch result {
                        
                    case .success(let url):
                        
                        self?.senderPhotoUrl = url
                        
                        DispatchQueue.main.async {
                            
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                        
                    case .failure(let error):
                        print(" error occured durring avatar image fetch \(error)")
                        
                    }
                    
                })
                
            }
            
        } else {
            
            // show other user image (sender)
            
            if let otherUserPhotoURL = self.otherUserPhotoUrl {
                
                avatarView.sd_setImage(with: otherUserPhotoURL, completed: nil)
            } else {
                
                // fetch url
                
                let email = self.otherUserEmail
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                let path = "images/\(safeEmail)_profile_picture.png"
                
                // fetch url
                
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    
                    switch result {
                        
                    case .success(let url):
                        
                        self?.otherUserPhotoUrl = url
                        
                        DispatchQueue.main.async {
                            
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                        
                    case .failure(let error):
                        print(" error occured durring avatar image fetch \(error)")
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    
    
}

extension ChatViewController: MessageCellDelegate {
    

    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
                
                return
            }
            
            let message = messages[indexPath.section]
            
            switch message.kind {
                
            case .location(let locationData):
                
                let coordinates = locationData.location.coordinate
                
                let vc = LocationPickerViewController(coordinates: coordinates)
                vc.title = "Location"
                
                navigationController?.pushViewController(vc, animated: true)
                
                
            default:
                
                break
        }
        
    }

    
    func didTapImage(in cell: MessageCollectionViewCell) {
    
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
            
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            
            let vc = PhotoViewerViewController(with: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
            
            
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }
            
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc,animated: true)
            vc.player?.play()
            
        default:
            
            break
    }
}

}
