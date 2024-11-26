//
//  SyntaxBuildable.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

/// A protocol for all structures that build and generate syntax
public protocol SyntaxBuildable {
    associatedtype Parameter
    
    func generateSyntax(with param: Parameter) -> String
}

public extension SyntaxBuildable {
    /// A helper function that takes a closure of syntax structures and transform it into the formatted Swift code
    /// - Parameter itemsBuilder: A closure for the syntax structures making up the outputted code
    /// - Returns: A `String` of formatted code
    func generateSyntaxBuilder(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> String {
        let syntax = SourceFileSyntax(
            statements: CodeBlockItemListSyntax {
                itemsBuilder()
            }
        )
        
        return syntax.formatted().description
    }
    
    /// A helper function that builds the syntax for an `import` statement
    /// - Parameters:
    ///   - module: The module being imported
    ///   - leadingTrivia: Any leading trivia
    ///   - trailingTrivia: Any trailing trivia
    /// - Returns: A `ImportDeclSyntax` with the specified trivia applied
    func buildImportSyntax(
        _ module: ImportModule,
        leadingTrivia: Trivia? = nil,
        trailingTrivia: Trivia? = nil
    ) -> ImportDeclSyntax {
        return ImportDeclSyntax(
            leadingTrivia: leadingTrivia,
            path: ImportPathComponentListSyntax {
                ImportPathComponentSyntax(
                    name: .identifier(module.rawValue)
                )
            },
            trailingTrivia: trailingTrivia
        )
    }
}

/// Possible imports used in the outputted syntax
public enum ImportModule: String {
    case argumentParser = "ArgumentParser"
    case deadline = "Deadline"
    case foundation = "Foundation"
    case packageDescription = "PackageDescription"
    case postgresNIO = "PostgresNIO"
    case spectreKit = "SpectreKit"
}
