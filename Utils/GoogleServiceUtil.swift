//
//  GoogleServiceUtil.swift
//  MyMessenger
//
//  Created by Sadık Çoban on 7.09.2022.
//

import Foundation


struct GoogleServiceUtil {
    static let shared = GoogleServiceUtil()
    
    func readFromPlist(with key: String) -> Any? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else { return nil }
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String: Any] else { return nil }
        guard let result = plist[key] else { return nil }
        return result
    }
}
