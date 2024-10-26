//
//  ESQLConstructorCLI.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/25/24.
//

import ArgumentParser

@main
struct ESQLConstructor: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "A utility to construct Swift files capable of processing ESQL Queries with the Phi Operator.",
        
        version: "1.0.0",
        
        subcommands: [])
}