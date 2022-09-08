//
//  DatabaseManager.swift
//  MyMessenger
//
//  Created by Sadık Çoban on 6.09.2022.
//

import Foundation
import FirebaseDatabase
import MessageKit

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

extension DatabaseManager {
    func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.database.child(path).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

// MARK: - Account Management
extension DatabaseManager {
    
    func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.hasChild("first_name") {
                completion(false)
                return
            }
            completion(true)
        }
        
    }
    
    /// Inserts new user to database
    func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue(["first_name": user.firstName, "last_name": user.lastName]) {[weak self] error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            guard let strongSelf = self else {
                completion(true)
                return
            }
            strongSelf.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // append to user dict
                    usersCollection.append(
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    )
                    
                    strongSelf.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                    
                } else {
                    // create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    strongSelf.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    
    
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], DatabaseError>) -> Void ) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    public enum DatabaseError: Error {
        case failedToFetch
    }
}






// MARK: - Chat Related Functions
extension DatabaseManager {
    
    /// Creates a new conversation with target user email and first message sent
    func createNewConversation(with otherUserEmail: String, receiverName: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child(safeEmail)
        ref.observeSingleEvent(of: .value) {[weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            switch firstMessage.kind {
                
            case .text(let msgText):
                message = msgText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationId = "conversation_\(firstMessage.messageId)"
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                "name": receiverName,
                "latest_message": [
                    "date": dateString,
                    "is_read": false,
                    "message": message
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "name": "Self",
                "latest_message": [
                    "date": dateString,
                    "is_read": false,
                    "message": message
                ]
            ]
            // UPdate Recipient conversation entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) {[weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    //append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                } else {
                    //create it
                    self?.database.child("\(otherUserEmail)/conversations").setValue([ recipient_newConversationData ])
                }
            }
            // Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exists for current user
                //append into it
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
            } else {
                // conversation array not exist, create it
                userNode["conversations"] = [ newConversationData ]
            }
            ref.setValue(userNode) {[weak self] error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                self?.finishCreatingConversation(conversationId: conversationId, receiverName: receiverName, firstMessage: firstMessage, completion: completion)
            }
        }
    }
    
    private func finishCreatingConversation(conversationId: String, receiverName: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        var content = ""
        switch firstMessage.kind {
            
        case .text(let msgText):
            content = msgText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let message: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": content,
            "date": dateString,
            "sender_email": DatabaseManager.safeEmail(emailAddress: currentUserEmail),
            "name": receiverName,
            "is_read": false
        ]
        let value: [String: Any] = [
            "messages": [
                message
            ]
        ]
        database.child(conversationId).setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Fetches and returns all conversations for the user with passed in email
    func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child( "\(email)/conversations").observe(.value) { snapshot in
            
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMessageObj = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObj)
            })
            completion(.success(conversations))
        }
    }
    
    /// Gets all messages for a given conversation
    func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child( "\(id)/messages").observe(.value) { snapshot in
            
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let _ = dictionary["is_read"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let date = dictionary["date"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let formattedDate = ChatViewController.dateFormatter.date(from: date),
                      let _ = dictionary["type"] as? String else { return nil }
                
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: messageId, sentDate: formattedDate, kind: .text(content))
            })
            completion(.success(messages))
        }
    }
    
    /// Sends a message with target conversation and message
    func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
}











struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    //   let profilePictureUrl: String
    var profilePictureFileName: String {
        "\(safeEmail)_profile_picture.png"
    }
}


