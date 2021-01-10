//
//  ProfileViewController.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 29/10/20.
//  Copyright © 2020 vladislav vaz. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage
import JGProgressHUD

final class ProfileViewController: UIViewController  {
    
    @IBOutlet var tableView: UITableView!
    
    private let spinner = JGProgressHUD(style: .light)
    
    
    var data = [ProfileViewModel]()
    
   // var urlProfile: URL!
    
    
    let imageView: UIImageView = {
       let theImageView = UIImageView()
       theImageView.translatesAutoresizingMaskIntoConstraints = true //calling this property adds the imageView to view
        
        theImageView.isUserInteractionEnabled = true
       return theImageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Name: \(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")",handler: nil))
        
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Email: \(UserDefaults.standard.value(forKey: "email") as? String ?? "No Email address")", handler: nil))
        
        data.append(ProfileViewModel(viewModelType: .logout, title: "Log out", handler: { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            let alertLogOut = UIAlertController(title: "Log out from Account?",
                                                       message: "",
                                                       preferredStyle: .alert)
                   
                   
                   alertLogOut.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
                       
                       guard let strongSelf = self else {
                           return
                       }
                   
                    UserDefaults.standard.setValue(nil, forKey: "email")
                    UserDefaults.standard.setValue(nil, forKey: "name")
                       
                       //Log out from facebook also
                       FBSDKLoginKit.LoginManager().logOut()
                       
                       //Log out from Google also
                       GIDSignIn.sharedInstance()?.signOut()
                       
                       do {
                           try FirebaseAuth.Auth.auth().signOut()
                           
                        
                        let vc = LoginViewController()
                        let nav = UINavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        strongSelf.present(nav, animated: true)
                        
                           
                       }
                           
                       catch {
                           
                           print("Failed to logout!")
                       }
                       
                       
                       
                   }))
                   
                   alertLogOut.addAction(UIAlertAction(title: "Cancel",
                                                       style: .cancel,
                                                       handler: nil))
                   
                   
            strongSelf.present(alertLogOut, animated: true)
            
        }))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.tableHeaderView = createTableHeader()
        
         let email = UserDefaults.standard.value(forKey: "email") as! String
               
               let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
               let filename = safeEmail + "_profile_picture.png"
               
               let path = "images/"+filename
               
               let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
               
               headerView.backgroundColor = .link
               
        
        tableView.tableHeaderView = headerView
        
        imageView.frame = CGRect(x: (view.width-250)/2, y: 31, width: 250, height: 250)
        
        //headerView.addSubview(imageView)
        //viewFrameImage.addSubview(imageView)

       // imageView.image = UIImage(named: "logo")
            // var imageView = UIImageView(frame: CGRect(x: (view.width-150)/2, y: 75, width: 150, height: 150))
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        imageView.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        
        imageView.addGestureRecognizer(tapGestureRecognizer)
               
        headerView.addSubview(imageView)
        
        spinner.show(in: imageView)
        
               //Adding tap gesture to the image
               
//              let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
//
//               imageView.addGestureRecognizer(tapGestureRecognizer)
           
               StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
           
                   
                   switch result {
                   case .success(let url):
                       //self?.downloadImage(imageView: imageView, url: url)
                    
                    self?.imageView.sd_setImage(with: url, completed: nil)
                    //self?.urlProfile = url
            
                    print("the url is \(url)")
                    
                    self?.spinner.dismiss()
               
                   case .failure(let error):
                       print("An error occured \(error)")
                   }
               })
        
    
    }
    

    @objc func imageTapped(sender: UITapGestureRecognizer)
    {
        
        
        ///presentPhotoActionSheet()  :-  function call not required
        
        
        let actionSheet = UIAlertController(title: "Profile Photo", message: "Select", preferredStyle: .alert)
        
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            actionSheet.addAction(UIAlertAction(title: "View Picture", style: .default, handler: { [weak self] _ in
                
                self?.viewProfilePic()
                
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
                
                self?.presentCamera()
                
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { [weak self]_ in
                
                self?.presentPhotoPicker()
            }))
            
            
            present(actionSheet, animated: true)
        
    
    }
    
    
    func presentPhotoActionSheet() {
        
        ///Function body - template 
        
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
    
    
    func viewProfilePic() {

     let secondVC = storyboard?.instantiateViewController(withIdentifier: "ViewProfilePicViewController") as! ViewProfilePicViewController
        secondVC.photo = imageView.image
     navigationController?.pushViewController(secondVC, animated: true)
        
    }
    

    
    
    func downloadImage(imageView: UIImageView, url: URL) {
        
        imageView.sd_setImage(with: url, completed: nil)
        
        
        DispatchQueue.main.async {
            
             self.tableView.reloadData()
            
        }
        
        //manually download the image everytime
        
//        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
//
//            guard let data = data, error == nil else {
//                return
//            }
//
//            DispatchQueue.main.async {
//
//                let image = UIImage(data: data)
//                imageView.image = image
//                // reload table after fetching the image (proper implementation later)
//                self.tableView.reloadData()
//            }
//
//            }).resume()
    }
    
    
}


extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let viewModel = data[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
        
    }
    
}

class ProfileTableViewCell: UITableViewCell {
    
    static let identifier = "ProfileTableViewCell"
    
    public func setUp(with viewModel: ProfileViewModel) {
        
        self.textLabel?.text = viewModel.title
        
        switch viewModel.viewModelType {
            
        case .info:
            textLabel?.textAlignment = .center
            //self.textLabel?.font = UIFont(name: "AppleSDGothicNeo-Heavy", size: 300)
            textLabel?.textColor = .link
            selectionStyle = .none
            
        
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
            
        }
        
        
    }
    
}


extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           
           picker.dismiss(animated: true, completion: nil)
           
           //print(info)
        
        spinner.show(in: imageView)
           
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
                   
                   StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { [weak self] result in
                       switch result {
                       case .success(let downloadUrl):
                           UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                           print(downloadUrl)
                           self?.spinner.dismiss()
                       case .failure(let error):
                           print("Storage maanger error: \(error)")
                       }
               
                   })
                   
           
       }
       
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           
           picker.dismiss(animated: true, completion: nil)
           
       }
    
    
    
    
    
}
