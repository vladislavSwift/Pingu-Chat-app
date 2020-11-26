//
//  StorageManager.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 10/11/20.
//  Copyright © 2020 vladislav vaz. All rights reserved.
//

import Foundation
import FirebaseStorage


final class StorageManager {
    
    static let shared = StorageManager()
    
    
    private let storage = Storage.storage().reference()
    
    
    /*
     
     Profile picture path will be something like
     
     /images/john-gmail-com_profile_picture.png
     
     */
    
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads picture to the Firebase Storage with the above path format and returns completion url to download the image
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            
            guard error == nil else {
                
                //fail message to console
                print("failed to store user profile picture")
                
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                
                guard let url = url else {
                    print("Failed to download the profile picture")
                    completion(.failure(StorageErrors.failedToDownloadUrl))
                    return
                }
                
                
                let urlString = url.absoluteString
                
                print("download url sucees and retured: \(urlString)")
                
                completion(.success(urlString))
                
            })
            
            
        })
        
    }
    
    /// Upload  conversation Images to firebase
    
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: {[weak self] metadata, error in
            
            guard error == nil else {
                
                //fail message to console
                print("failed to store user picture message")
                
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                
                guard let url = url else {
                    print("Failed to download the picture message")
                    completion(.failure(StorageErrors.failedToDownloadUrl))
                    return
                }
                
                
                let urlString = url.absoluteString
                
                print("download url sucees and retured: \(urlString)")
                
                completion(.success(urlString))
                
            })
            
            
        })
        
    }
    
    /// Upload  video message  to firebase
    
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        
       // storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: {[weak self] metadata, error in
        
        
        // remove metadata and remove the if let statement for reverting back
        
//        let metadata = StorageMetadata()
//
//        metadata.contentType = "video/quicktime"
//
//
      if let videoData = NSData(contentsOf: fileUrl) as Data? {
            
        
        
        storage.child("message_videos/\(fileName)").putData(videoData, metadata: nil, completion: {[weak self] metadata, error in
            
            guard error == nil else {
                
                //fail message to console
                print("failed to store video message url ")
                
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                
                guard let url = url else {
                    print("Failed to download video message url")
                    completion(.failure(StorageErrors.failedToDownloadUrl))
                    return
                }
                
                
                let urlString = url.absoluteString
                
                print("download url sucees and retured: \(urlString)")
                
                completion(.success(urlString))
                
            })
            
            
        })
            
        }
        
    }
    
    
    public enum StorageErrors: Error {
        
        case failedToUpload
        case failedToDownloadUrl
        
    }
    
    public func downloadURL(for path: String, completion:  @escaping (Result<URL, Error>) -> Void) {
        
        let reference = storage.child(path)
        
        reference.downloadURL(completion: {url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToDownloadUrl))
                return
            }
            
            completion(.success(url))
        })
        
    }
    
    
}
