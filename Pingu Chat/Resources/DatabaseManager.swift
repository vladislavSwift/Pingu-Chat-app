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
        
        
        database.child(email).observeSingleEvent(of: .value, with: { snapshot in
            
            guard snapshot.value as? String != nil else {
                
                completion(false)
                return
            }
            
            completion(true)
            
        })
    
    }
    
    
    /// Inserts Users to database
    
    public func insertUser(with user: ChatAppUser) {
        
        database.child(user.emailAddress).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
            
        ])
        
    }
    
}

struct ChatAppUser {
    
    let firstName: String
    let lastName: String
    let emailAddress: String
    //un-encrypted password
    //let password:String
    
    //let profilePictureUrl: String
}
