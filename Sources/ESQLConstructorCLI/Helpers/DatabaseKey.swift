//
//  DatabaseKey.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/26/24.
//

import Foundation

/// An enum that stores the `UserDefaults` key for database credentials
enum DatabaseKey: String {
    case host = "PE_Host"
    case port = "PE_Port"
    case username = "PE_Username"
    case password = "PE_Password"
    case database = "PE_Database"
}
