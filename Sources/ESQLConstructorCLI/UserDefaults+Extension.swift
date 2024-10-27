//
//  UserDefaults+Extension.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/26/24.
//

import Foundation

extension UserDefaults {
    func setValue(_ value: Any?, forKey key: DatabaseKey) {
        self.set(value, forKey: key.rawValue)
    }
    
    func string(forKey key: DatabaseKey) -> String? {
        return self.string(forKey: key.rawValue)
    }
    
    func integer(forKey key: DatabaseKey) -> Int? {
        return self.integer(forKey: key.rawValue)
    }
    
    func removeObject(forKey key: DatabaseKey) {
        self.removeObject(forKey: key.rawValue)
    }
}
