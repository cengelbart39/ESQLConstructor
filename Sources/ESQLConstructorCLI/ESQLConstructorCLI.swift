//
//  ESQLConstructorCLI.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/25/24.
//  CWID: 10467610
//

import ArgumentParser
import Foundation

@main
struct ESQLConstructorCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A utility to construct Swift files capable of processing ESQL Queries with the Phi Operator.",
        version: "1.0.0",
        // Assign commands
        subcommands: [Setup.self, ConstructorWithFile.self, ConstructorWithArguments.self]
    )
}
