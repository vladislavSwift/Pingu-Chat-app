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

final class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    
    var data = [ProfileViewModel]()
    
    
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
                                                       preferredStyle: .actionSheet)
                   
                   
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
        tableView.tableHeaderView = createTableHeader()
        
        
    }
    
    
    func createTableHeader() -> UIView? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        
        let path = "images/"+filename
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (view.width-150)/2, y: 75, width: 150, height: 150))
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
    
            
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: imageView, url: url)
                
                
            case .failure(let error):
                print("An error occured \(error)")
            }
        })
        
        return headerView
    
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
