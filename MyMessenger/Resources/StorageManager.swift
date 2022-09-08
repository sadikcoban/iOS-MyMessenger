//
//  StorageManager.swift
//  MyMessenger
//
//  Created by Sadık Çoban on 8.09.2022.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    // images/some-mail-com_prpfile_picture.png
    
    public typealias UploadPictureCompletion = (Result<String, StorageErrors>) -> Void
    
    /// Uploads picture to firebase storage and returns completion with url string to download when succeeded, or error otherwise.
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data) {[weak self] metaData, error in
            guard error == nil else {
                completion(.failure(.failedToUpload))
                return
            }
            self?.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("Download URL: " + urlString)
                completion(.success(urlString))
            }
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, StorageErrors>) -> Void) {
        let reference = storage.child(path)
        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        }
    }
}
