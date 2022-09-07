//
//  ChatViewController.swift
//  MyMessenger
//
//  Created by Sadık Çoban on 7.09.2022.
//

import UIKit
import MessageKit


struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    private let selfSender = Sender(photoURL: "", senderId: "1", displayName: "Joe Smith")
    private let incomingSender = Sender(photoURL: "", senderId: "2", displayName: "Sadik Cobane")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        messages.append(Message(sender: selfSender, messageId: "2", sentDate: Date(), kind: .text("Hello world!!")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello My Name is Joe, I hope You are having a great day!!")))
        messages.append(Message(sender: incomingSender, messageId: "3", sentDate: Date(), kind: .text("Hello Joe!!")))
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    
}
