//
//  ProfileViewModel.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 04/01/21.
//  Copyright © 2021 vladislav vaz. All rights reserved.
//

import Foundation

enum ProfileViewModelType {
    
    case info, logout
    
}


struct ProfileViewModel {
    
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
    
}
