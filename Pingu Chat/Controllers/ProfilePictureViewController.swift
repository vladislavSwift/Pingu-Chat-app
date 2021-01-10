//
//  ProfilePictureViewController.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 05/01/21.
//  Copyright © 2021 vladislav vaz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

final class ProfilePictureViewController: UIViewController {
    
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
        title = "Edit Profile picture"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .black
        
        
        
        let edit = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(editPicTapped))
        let done = UIBarButtonItem(title: "done", style: .plain, target: self, action: #selector(doneTapped))
        
        navigationItem.rightBarButtonItems = [done, edit]
        
        
        view.addSubview(imageView)
        imageView.sd_setImage(with: url, completed: nil)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        tabBarController?.tabBar.isHidden = true
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
         tabBarController?.tabBar.isHidden = false
        
    }
    
    
    @objc private func editPicTapped(){
        
        presentPhotoActionSheet()
        
       
        
    }
    
    @objc private func doneTapped(){
        

         navigationController?.popViewController(animated: true)
        
        
        
    }
    
    
    
}


extension ProfilePictureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        
         let actionSheet = UIAlertController(title: "Choose Profile Photo", message: "Open With", preferredStyle: .alert)
               
               actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               
               actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
                   
                   self?.presentCamera()
                   
               }))
               
               actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { [weak self]_ in
                   
                   self?.presentPhotoPicker()
               }))
               
               
               present(actionSheet, animated: true)
        
    }
    
    
    func presentCamera() {
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
        
    }
    
    func presentPhotoPicker() {
        
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        //print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return}
        
        self.imageView.image = selectedImage
        
        // upload image
                guard let image = self.imageView.image,
                    let data = image.pngData() else {
                        return
                }
                
               
                 
               let fullName = UserDefaults.standard.value(forKey: "name") as! String
                let email = UserDefaults.standard.value(forKey: "email") as! String

                
                let fullNameArr = fullName.components(separatedBy: " ")

                let firstName = fullNameArr[0]
                let lastName = fullNameArr[1]
                
                
                let chatUser = ChatAppUser(firstName: firstName,
                lastName: lastName,
                emailAddress: email)
                
                
                //let filename = chatUser.profilePictureFileName
                
                let filename = chatUser.profiePictureFileName
                
                StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                    switch result {
                    case .success(let downloadUrl):
                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                        print(downloadUrl)
                    case .failure(let error):
                        print("Storage maanger error: \(error)")
                    }
            
                })
                
        //        NSNotificationCenter.defaultCenter().
        //        postNotificationName("newDataNotif", object: nil)
                
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newProfilePic"), object: nil)
        
        
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}
