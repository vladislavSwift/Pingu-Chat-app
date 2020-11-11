//
//  DatabaseManager.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 02/11/20.
//  Copyright © 2020 vladislav vaz. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    
    
}

//MARK:- Account Management


extension DatabaseManager {
    
    
    public func userWithEmailExists(with email: String,
                                    completion: @escaping((Bool) -> Void)) {
        
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            
            guard snapshot.value as? String != nil else {
                
                completion(false)
                return
            }
            
            completion(true)
            
        })
    
    }
    
    
    /// Inserts Users to database
    
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        
        
        
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
            
        ], withCompletionBlock: { error, _ in
            
            guard  error == nil else {
                
                print("failed to write to database")
                
                completion(false)
                return
            }
            
            completion(true)
            
        })
        
    }
    
}

struct ChatAppUser {
    
    let firstName: String
    let lastName: String
    let emailAddress: String
    //un-encrypted password
    //let password:String
    
    var profiePictureFileName: String {
        
        return "\(safeEmail)_profile_picture.png"
    }
    
    

    var safeEmail: String {
        
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        return safeEmail
    }
}
