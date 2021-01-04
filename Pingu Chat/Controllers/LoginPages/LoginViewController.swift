//
//  LoginViewController.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 29/10/20.
//  Copyright © 2020 vladislav vaz. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

final class LoginViewController: UIViewController {
    
    
    private let spinner = JGProgressHUD(style: .dark)
    
    
    private let scrollView: UIScrollView = {
        
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Enter Email Address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    
    
    private let passwordField: UITextField = {
        
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Enter Password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.isSecureTextEntry = true
        return field
    }()
    
    
    private let loginButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
        
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        
        let fbButton = FBLoginButton()
        fbButton.permissions = ["email,public_profile"]
        fbButton.layer.cornerRadius = 12
        fbButton.layer.masksToBounds = true
        return fbButton
    }()
    
    
    private let googleLogInButton = GIDSignInButton()
    
    // rounded corners
    /*
     private let googleLogInButton: GIDSignInButton = {
     
     let googleButton = GIDSignInButton()
     googleButton.layer.cornerRadius = 12
     googleButton.layer.masksToBounds = true
     return googleButton
     
     }()
     
     */
    
    private var loginObserver: NSObjectProtocol?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
            
        })
        
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        title = "Log In"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginButton.delegate = self
        
        
        //Adding subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLogInButton)
    }
    
    deinit {
        if let observer = loginObserver {
            
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2, y: 20, width: size, height: size)
        
        emailField.frame = CGRect(x: 30, y: imageView.bottom+10, width: scrollView.width-60, height: 40)
        
        passwordField.frame = CGRect(x: 30, y: emailField.bottom+10, width: scrollView.width-60, height: 40)
        
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom+10, width: scrollView.width-60, height: 40)
        
        //button to look like the login button
        //facebookLoginButton.frame = CGRect(x: 30, y: loginButton.bottom+10, width: scrollView.width-60, height: 40)
        
        facebookLoginButton.center = scrollView.center
        facebookLoginButton.frame.origin.y = loginButton.bottom + 10
        
        googleLogInButton.center = scrollView.center
        googleLogInButton.frame.origin.y = facebookLoginButton.bottom + 10
        
    }
    
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text,
            let password = passwordField.text,
            !email.isEmpty,
            !password.isEmpty,
            password.count >= 6 else {
                
                alertUserLoginError()
                
                return
        }
        
        
        spinner.show(in: view)
        
        //Perform firebase login
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            
            
            
            guard let strongSelf = self else {
                
                return
            }
            
            DispatchQueue.main.async {
                
                strongSelf.spinner.dismiss()
                
            }
            
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                
                switch result {
                    
                case .success(let data):
                    guard let userData = data as? [String: Any],
                        let firstName = userData["first_name"] as? String,
                    let lastName = userData["last_name"] as? String else {
                    
                        
                        return
                    }
                    
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    
                    
                    
                case .failure(let error):
                    print("failed to read data with error in loginViewController \(error)")
                }
                
                
            })
            
            
            UserDefaults.standard.set(email, forKey: "email")
            
            
            print("logged in user:\(user)")
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
        })
        
        
    }
    
    
    func alertUserLoginError() {
        
        let alert = UIAlertController(title: "Error", message: "Please enter all info to proceed", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert,animated: true)
        
        
    }
    
    
    
    
    @objc private func didTapRegister() {
        
        let vc = RegisterViewController()
        vc.title = "Create New Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}


extension LoginViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            
            passwordField.becomeFirstResponder()
            
        } else if textField == passwordField {
            
            loginButtonTapped()
        }
        
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        //Not displaying the logout button from fb
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        spinner.show(in: view)
        
        guard let token = result?.token?.tokenString else {
            print("User Failed to log in with Facebook")
            spinner.dismiss()
            return
        }
        
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        
        facebookRequest.start(completionHandler: { _, result, error in
            
            guard let result = result as? [String: Any], error == nil else {
                
                print("failed to make facebook graph request")
                return
            }
            
            // print("Result \(result)")
            
            guard let firstName = result["first_name"] as? String,
                let lastName = result["last_name"] as? String,
                let email = result["email"] as? String,
                let picture = result["picture"] as? [String: Any],
                let data = picture["data"] as? [String: Any],
                let pictureUrl = data["url"] as? String  else {
                    
                    print("Failed to get email and name from fb account")
                    return
            }
            
            
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            
            DatabaseManager.shared.userWithEmailExists(with: email, completion: { exists in
                
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        
                        if success {
                            
                            guard let url = URL(string: pictureUrl) else {
                                
                                return
                            }
                            
                            URLSession.shared.dataTask(with: url,completionHandler: { data, _, _ in
                                
                                guard let data = data else {
                                    
                                    return
                                }
                                
                                // upload profile picture
                                
                                let fileName = chatUser.profiePictureFileName
                                
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                                    
                                    switch result {
                                        
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("storage manager error \(error)")
                                    }
                                    
                                })
                                
                            }).resume()
                            
                        }
                        
                    })
                }
                
            })
            
            let credentials = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credentials, completion: { [weak self] authResult, error in
                
                guard let strongSelf = self else {
                    
                    return
                }
                
                
                guard authResult != nil, error == nil else {
                    
                    if let error = error {
                        
                        print("Facebook credential login failed - \(error)")
                        
                        strongSelf.spinner.dismiss()
                        
                    }
                    
                    
                    return
                }
                
                print("Successfully logged user log in")
                
            strongSelf.spinner.dismiss()
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
        })
        
    }
    
}

