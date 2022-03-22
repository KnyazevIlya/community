//
//  UserDefaults+Extension.swift
//  community
//
//  Created by Illia Kniaziev on 22.03.2022.
//

import Foundation

public enum UserPreferences: String, CaseIterable {
    
    case uploadQueue = "com.community.uploadQueue"
    
    func getData<T: Decodable>() -> T? {
        guard let data = UserDefaults.standard.object(forKey: rawValue) as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func saveData<T: Encodable>(of json: T) {
        let data = try? JSONEncoder().encode(json)
        UserDefaults.standard.set(data, forKey: rawValue)
    }
    
    func remove() {
        UserDefaults.standard.set(nil, forKey: rawValue)
    }
    
    static func removeAll() {
        for item in UserPreferences.allCases {
            item.remove()
        }
    }
}
