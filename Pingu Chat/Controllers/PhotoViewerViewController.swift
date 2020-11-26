//
//  PhotoViewerViewController.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 29/10/20.
//  Copyright © 2020 vladislav vaz. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController, UIScrollViewDelegate {
    
    private let url: URL

    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView


    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photos"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .black
        view.addSubview(imageView)
        imageView.sd_setImage(with: self.url, completed: nil)
        
        
    }
    
    

    
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        
        
        imageView.frame = view.bounds

    }
    


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.hidesBarsOnTap = true
               
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.navigationController?.hidesBarsOnTap = false
        
        self.tabBarController?.tabBar.isHidden = false
    }
    

    
}


