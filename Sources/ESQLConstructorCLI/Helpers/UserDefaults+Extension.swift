//
//  UserDefaults+Extension.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/26/24.
//  CWID: 10467610
//

import Foundation

extension UserDefaults {
    /// Convenience function to set the value of a ``DatabaseKey``
    func setValue(_ value: Any?, forKey key: DatabaseKey) {
        self.set(value, forKey: key.rawValue)
    }
    
    /// Convenience function to get the `String` at a ``DatabaseKey``
    func string(forKey key: DatabaseKey) -> String? {
        return self.string(forKey: key.rawValue)
    }
    
    /// Convenience function to get the `Int` at a ``DatabaseKey``
    func integer(forKey key: DatabaseKey) -> Int? {
        return self.integer(forKey: key.rawValue)
    }
    
    /// Convenience function to remove the value at a ``DatabaseKey``
    func removeObject(forKey key: DatabaseKey) {
        self.removeObject(forKey: key.rawValue)
    }
}
