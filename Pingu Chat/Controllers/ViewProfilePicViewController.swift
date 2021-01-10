//
//  ViewProfilePicViewController.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 09/01/21.
//  Copyright © 2021 vladislav vaz. All rights reserved.
//

import UIKit

class ViewProfilePicViewController: UIViewController {
    
    @IBOutlet weak var profilePicLarge: UIImageView!
    
    var photo: UIImage!
    
//        private let imageView: UIImageView = {
//           let imageView = UIImageView()
//           imageView.contentMode = .scaleAspectFit
//           return imageView
//       }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile Picture"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .black
        
        
       // view.addSubview(imageView)
       // imageView.sd_setImage(with: nil, completed: nil)
        
        self.profilePicLarge.image = photo
        

    }
    
    
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
         // imageView.frame = view.bounds
      }
      
      
      override func viewWillAppear(_ animated: Bool) {
          
          super.viewWillAppear(true)
          
          tabBarController?.tabBar.isHidden = true
          
          
      }
      
      
      override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(true)
          
           tabBarController?.tabBar.isHidden = false
          
      }
    


}
