
//
//  PhotoViewerViewController.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 29/10/20.
//  Copyright © 2020 vladislav vaz. All rights reserved.
//

import UIKit
import SDWebImage

final class PhotoViewerViewController: UIViewController, UIScrollViewDelegate {
    
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
        view.backgroundColor = .red
        view.addSubview(imageView)
        imageView.sd_setImage(with: url, completed: nil)
        
//        let vWidth = self.view.frame.width
//        let vHeight = self.view.frame.height
//
//
//        let frameSize = CGRect(x: 0, y: 0, width: vWidth, height: vHeight)

        let scrollImg: UIScrollView = UIScrollView()
        scrollImg.delegate = self
        //scrollImg.frame = CGRect(x: 0, y: 0, width: vWidth, height: vHeight)
        //scrollImg.backgroundColor = UIColor(red: 90, green: 90, blue: 90, alpha: 0.90)
        scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = false
        scrollImg.showsHorizontalScrollIndicator = false
        scrollImg.flashScrollIndicators()

        scrollImg.bounces = false
        scrollImg.bouncesZoom = false
        
        scrollImg.clipsToBounds = true
        
        
        scrollImg.minimumZoomScale = 2.0
        scrollImg.maximumZoomScale = 10.0
        
        scrollImg.zoomScale = 1.0
        
        

        view.addSubview(scrollImg)

       // imageView.layer.cornerRadius = 11.0
        imageView.clipsToBounds = true
        
        
        imageView.frame = view.bounds
        
        
        scrollImg.frame = view.bounds
        
        scrollImg.backgroundColor = .black
        
        //self.automaticallyAdjustsScrollViewInsets =
        scrollImg.automaticallyAdjustsScrollIndicatorInsets = true
        
        
        //automaticallyAdjustsScrollViewInsets = false
        
        scrollImg.addSubview(imageView)
        
        
    }
    

    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        
        
       // imageView.frame = view.bounds
        
       
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       // navigationController?.setNavigationBarHidden(true, animated: true)
        
        navigationController?.hidesBarsOnTap = true
               //navigationController?.setNavigationBarHidden(true, animated: true)

        tabBarController?.tabBar.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        navigationController?.hidesBarsOnTap = false
        
        tabBarController?.tabBar.isHidden = false
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    

    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {

        if scrollView.zoomScale > 1 {

            if let image = imageView.image {

                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height

                let ratio = ratioW < ratioH ? ratioW:ratioH

                let newWidth = image.size.width*ratio
                let newHeight = image.size.height*ratio

                let left = 0.5 * (newWidth * scrollView.zoomScale > imageView.frame.width ? (newWidth - imageView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                let top = 0.5 * (newHeight * scrollView.zoomScale > imageView.frame.height ? (newHeight - imageView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))

                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = UIEdgeInsets.zero
        }
    }

    
}
