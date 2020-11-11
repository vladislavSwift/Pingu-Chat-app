//
//  NewConversationViewController.swift
//  Pingu Chat
//
//  Created by vladislav vaz on 29/10/20.
//  Copyright © 2020 vladislav vaz. All rights reserved.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    
    private let spinner = JGProgressHUD()
    
    private let searchBar: UISearchBar = {
        
       let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users"
        
        return searchBar
        
    }()
    
    
    private let tableView: UITableView = {
        
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
        
    }()
    
    
    private let noResultsLabel: UILabel = {
        
        let label = UILabel()
        label.isHidden = true
        label.text = "No Users Found"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        view.backgroundColor = .systemPink
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSearch))
        
        searchBar.becomeFirstResponder()
        
    }
    
    
    @objc private func dismissSearch() {
        
        dismiss(animated: true, completion: nil)
        
    }

    

}


extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        
    }
    
}
