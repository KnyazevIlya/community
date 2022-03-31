//
//  UserDefaults+Extension.swift
//  community
//
//  Created by Illia Kniaziev on 22.03.2022.
//

import Foundation

extension UserDefaults {
    
    static func saveData<T: Encodable>(of object: T, forKey key: String) {
        let data = try? JSONEncoder().encode(object)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    static func getData<T: Decodable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    static func remove(forKey key: String) {
        UserDefaults.standard.set(nil, forKey: key)
    }
    
}
