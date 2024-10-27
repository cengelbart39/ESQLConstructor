//
//  ConstructorWithFile.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/26/24.
//

import ArgumentParser
import ESQLConstructor
import Foundation

extension ESQLConstructorCLI {
    struct ConstructorWithFile: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "constructor-file",
            abstract: "Creates an output package using the Phi operator's parameters from a file and database credentials"
        )
        
        @Option(name: [.short, .customLong("input")], help: "The path of the input file")
        var inputPath: String
        
        @Option(name: [.short, .customLong("output")], help: "The path of the output files")
        var outputPath: String
        
        func validate() throws {
            let host = UserDefaults.standard.string(forKey: .host)
            let port = UserDefaults.standard.integer(forKey: .port)
            let username = UserDefaults.standard.string(forKey: .username)
            
            guard host != nil && port != nil && username != nil else {
                throw ValidationError.notSetup
            }
        }
        
        func run() throws {
            let phi = try FileHandler.constructPhi(from: inputPath)
            
            let service = PostgresService(
                host: UserDefaults.standard.string(forKey: .host)!,
                port: UserDefaults.standard.integer(forKey: .port)!,
                username: UserDefaults.standard.string(forKey: .username)!,
                password: UserDefaults.standard.string(forKey: .password),
                database: UserDefaults.standard.string(forKey: .database)
            )
            
            try FileHandler.createOutputFiles(at: outputPath, with: phi, using: service)
        }
    }
}

enum ValidationError: Error, LocalizedError {
    case notSetup
    
    var errorDescription: String? {
        switch self {
        case .notSetup:
            return "Please use the \"setup\" command to set up and verify your database credentials."
        }
    }
}
