//
//  PostgresService.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/25/24.
//  CWID: 10467610
//

import PostgresNIO
import Deadline

public struct PostgresService : Sendable {
    public let client: PostgresClient
    
    public let host: String
    public let port: Int
    public let username: String
    public let password: String?
    public let database: String?
    
    public init(host: String, port: Int = 5432, username: String, password: String? = nil, database: String? = nil) {
        let config = PostgresClient.Configuration(
            host: host,
            port: port,
            username: username,
            password: password,
            database: database,
            tls: .disable)
        
        self.client = PostgresClient(configuration: config)
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.database = database
    }
    
    /// Attempts to connects database and run `select version()` to verify credentials
    /// - Returns: Whether it was successful
    /// - Note: `PostgresNIO` has no way to verify the credentials without querying the database.
    /// To get around this, we query `select version()` and wait 15 seconds the query operation to complete.
    public func verify() async -> Bool {
        do {
            try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask {
                    await self.client.run()
                }
                
                print("Querying \"select version()\"... Waiting 15 seconds for response...")
                
                let rows = try await withDeadline(until: .now + .seconds(15)) {
                    try await self.client.query("select version()")
                }
                
                for try await version in rows.decode(String.self) {
                    print("Query Response: \(version)")
                }
                
                taskGroup.cancelAll()
            }
            
            return true
            
        // If the task group errors, the connection is unable to be used
        } catch {
            return false
        }
    }
}
