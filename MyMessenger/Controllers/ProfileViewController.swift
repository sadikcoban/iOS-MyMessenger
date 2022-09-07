//
//  ProfileViewController.swift
//  MyMessenger
//
//  Created by Sadık Çoban on 6.09.2022.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: {[weak self] _ in
            guard let strongSelf = self else { return }
            
            //Google Log out
            GIDSignIn.sharedInstance.signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            } catch {
                print("unable to sign out user")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
        
    }
}
