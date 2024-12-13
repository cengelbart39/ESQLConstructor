//
//  ConstructorWithFile.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/26/24.
//  CWID: 10467610
//

import ArgumentParser
import ESQLConstructor
import Foundation

extension ESQLConstructorCLI {
    struct ConstructorWithFile: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "constructor-file",
            abstract: "Creates an output package using the Phi operator's parameters from a file and database credentials",
            discussion: """
                        The input file should be 5 or 6 lines. The having predicate can be excluded.
                        
                        1st Line: Comma-seperated string of projected values
                        2nd Line: Number of grouping variables
                        3rd Line: Comma-seperated string of group-by attributes
                        4th Line: Comma-seperated string of grouping variables 
                        5th Line: Comma-seperated strings of groupung variable aggregate functions
                        6th Line: Having predicate as a string (can copy-paste SQL)
                        """
        )
        
        @Option(name: [.short, .customLong("input")], help: "The path of the input file")
        var inputPath: String
        
        @Option(name: [.short, .customLong("output")], help: "The path of the output files")
        var outputPath: String
        
        /// Validates that the host, port, and username credentials are in `UserDefaults`
        /// - Throws: ``ValidationError/notSetup`` if any of the above aren't present
        func validate() throws {
            let host = UserDefaults.standard.string(forKey: .host)
            let port = UserDefaults.standard.integer(forKey: .port)
            let username = UserDefaults.standard.string(forKey: .username)
            
            guard host != nil && port != nil && username != nil else {
                throw ValidationError.notSetup
            }
        }
        
        func run() throws {
            // Attempt to get phi
            let phi = try FileHandler.constructPhi(from: inputPath)
            
            // Create PostgresService
            let service = PostgresService(
                host: UserDefaults.standard.string(forKey: .host)!,
                port: UserDefaults.standard.integer(forKey: .port)!,
                username: UserDefaults.standard.string(forKey: .username)!,
                password: UserDefaults.standard.string(forKey: .password),
                database: UserDefaults.standard.string(forKey: .database)
            )
            
            // Create output files
            try FileHandler.createOutputFiles(at: outputPath, with: phi, using: service)
            print("Successfully created files at \(outputPath).")
        }
    }
}

/// Error thrown during validation
enum ValidationError: Error, LocalizedError {
    case notSetup
    
    var errorDescription: String? {
        switch self {
        case .notSetup:
            return "Please use the \"setup\" command to set up and verify your database credentials."
        }
    }
}
