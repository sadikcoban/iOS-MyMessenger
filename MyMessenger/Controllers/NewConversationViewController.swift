//
//  NewConversationViewController.swift
//  MyMessenger
//
//  Created by Sadık Çoban on 6.09.2022.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private lazy var spinner: JGProgressHUD = {
        let view = JGProgressHUD(style: .dark)
        return view
    }()
    
    private lazy var noResultLabel: UILabel = {
        let view = UILabel()
        view.text = "No Results"
        view.textAlignment = .center
        view.textColor = .gray
        view.font = .systemFont(ofSize: 21, weight: .medium)
        view.isHidden = true
        return view
    }()
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search for users..."
        return bar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    

    @objc private func dismissSelf(){
        dismiss(animated: true)
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
