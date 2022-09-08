//
//  NewConversationViewController.swift
//  MyMessenger
//
//  Created by Sadık Çoban on 6.09.2022.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    public var completion: (([String: String]) -> Void)?
    
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var hasFetched = false
    
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
        view.addSubview(tableView)
        view.addSubview(noResultLabel)
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
        loadAllUsers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width/2, height: 200)
    }
    @objc private func dismissSelf(){
        dismiss(animated: true)
    }
    
    private func loadAllUsers(){
        spinner.show(in: view)
        DatabaseManager.shared.getAllUsers {[weak self] result in
            switch result {
            case .success(var usersCollection):
                self?.hasFetched = true
                self?.hasFetched = true
                if let email = UserDefaults.standard.value(forKey: "email") as? String {
                    let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                    usersCollection.removeAll(where: { $0["email"] == safeEmail })
                }
                self?.users = usersCollection
                self?.results = usersCollection
                self?.updateUI()
            case .failure(let error):
                print("failed to get users: \(error)")
            }
        }
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        searchUsers(query: text)
    }
    
    func searchUsers(query: String){
        // check if array has firebase result
        if hasFetched {
            //if yes filter
            filterUsers(with: query)
        } else {
            //if not fetch then filter
            DatabaseManager.shared.getAllUsers {[weak self] result in
                switch result {
                case .success(var usersCollection):
                    self?.hasFetched = true
                    if let email = UserDefaults.standard.value(forKey: "email") as? String {
                        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                        usersCollection.removeAll(where: { $0["email"] == safeEmail })
                    }

                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("failed to get users: \(error)")
                }
            }
        }
        
    }
    
    func filterUsers(with term: String) {
        //update ui, either show results or no results
        guard hasFetched else { return }
        self.spinner.dismiss(animated: true)
        let results: [[String: String]] = self.users.filter {
            guard let name = $0["name"]?.lowercased() as? String else { return false }
            return name.hasPrefix(term.lowercased())
        }
        self.results = results
        updateUI()
    }
    
    private func updateUI(){
        if results.isEmpty {
            self.noResultLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noResultLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
        spinner.dismiss()
    }
}


extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start conversation
        let targetUserData = results[indexPath.row]
        dismiss(animated: true) {[weak self] in
            self?.completion?(targetUserData)
        }
    }
    
}
