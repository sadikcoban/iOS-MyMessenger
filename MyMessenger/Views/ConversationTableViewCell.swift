//
//  ConversationTableViewCell.swift
//  MyMessenger
//
//  Created by Sadık Çoban on 8.09.2022.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private lazy var userImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 50
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private lazy var userNameLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 21, weight: .semibold)
        
        return view
    }()
    
    private lazy var userMessageLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 19, weight: .regular)
        view.numberOfLines = 0
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)
        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height-20)/2)
        userMessageLabel.frame = CGRect(x: userImageView.right + 10,
                                        y: userNameLabel.bottom + 10,
                                        width: contentView.width - 20 - userImageView.width,
                                        height: (contentView.height-20)/2)
        
        
    }
    
    public func configure(with model: Conversation) {
        self.userMessageLabel.text = model.latestMessage.text
        self.userNameLabel.text = model.name
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self.userImageView.sd_setImage(with: url)
                }
            case .failure(let error):
                print("unable to download image: \(error)")
            }
        }
    }
    
}
