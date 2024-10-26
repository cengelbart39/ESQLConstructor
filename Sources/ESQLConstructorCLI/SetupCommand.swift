//
//  SetupCommand.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/26/24.
//

import ArgumentParser
import Foundation
import ESQLConstructor

extension ESQLConstructorCLI {
    struct Setup: AsyncParsableCommand {
        @Option(name: [.long], help: "The hostname to connect to")
        var host: String
        
        @Option(name: .long, help: "The TCP port to connect to")
        var port: Int = 5432
        
        @Option(name: .long, help: "The username to connect with")
        var username: String
        
        @Option(name: .long, help: "The password to connect with, if any")
        var password: String?
        
        @Option(name: .long, help: "The database to connect to, if any")
        var database: String?
        
        func run() async throws {
            let service = PostgresService(
                host: host,
                port: port,
                username: username,
                password: password,
                database: database
            )
            
            let canQuery = await service.verify()
            
            if canQuery {
                print("Verified Credentials.")
                
                UserDefaults.standard.setValue(host, forKey: .host)
                UserDefaults.standard.setValue(port, forKey: .port)
                UserDefaults.standard.setValue(username, forKey: .username)
                UserDefaults.standard.setValue(password, forKey: .password)
                UserDefaults.standard.setValue(database, forKey: .database)
                
                print("Saved Database Credentials.")
            }
        }
    }
}
