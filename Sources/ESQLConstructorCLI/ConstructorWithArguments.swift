//
//  ConstructorWithArguments.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/26/24.
//

import ArgumentParser
import ESQLConstructor
import Foundation

extension ESQLConstructorCLI {
    struct ConstructorWithArguments: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "constructor-cmdline",
            abstract: "Creates an output package using the Phi operator's parameters from the command line and database credentials"
        )
        
        @Option(name: [.customShort("S")], help: "A comma-seperated string of projected values of the query")
        var projectedValues: String
        
        @Option(name: [.customShort("n")], help: "The number of grouping variables in the query")
        var numOfGroupingVars: Int
        
        @Option(name: [.customShort("V")], help: "A comma-seperated string of group by attributes of the query")
        var groupByAttributes: String
        
        @Option(name: [.customShort("F")], help: "A comma-seperated string of aggregates for grouping variables in the query")
        var aggregates: String
        
        @Option(name: [.customShort("s")], help: "A comma-seperated string of grouping variable predicates in the query")
        var groupingVarPredicates: String
        
        @Option(name: [.customShort("G")], help: "A comma-seperated string ofof having predicates in the query, if any")
        var havingPredicates: String?
        
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
            var phiString: String {
                if let having = havingPredicates {
                    "\(projectedValues)\n\(numOfGroupingVars)\n\(groupByAttributes)\n\(aggregates)\n\(groupingVarPredicates)\n\(having)"
                } else {
                    "\(projectedValues)\n\(numOfGroupingVars)\n\(groupByAttributes)\n\(aggregates)\n\(groupingVarPredicates)"
                }
            }
            
            let phi = try Phi(string: phiString)
            
            let service = PostgresService(
                host: UserDefaults.standard.string(forKey: .host)!,
                port: UserDefaults.standard.integer(forKey: .port)!,
                username: UserDefaults.standard.string(forKey: .username)!,
                password: UserDefaults.standard.string(forKey: .password),
                database: UserDefaults.standard.string(forKey: .database)
            )
            
            try FileHandler.createOutputFiles(at: outputPath, with: phi, using: service)
            
            print("Successfully created files at \(outputPath).")
        }
    }
}