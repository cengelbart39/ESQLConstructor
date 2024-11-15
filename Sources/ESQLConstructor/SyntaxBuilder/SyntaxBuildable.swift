//
//  SyntaxBuildable.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public protocol SyntaxBuildable {
    associatedtype Parameter
    
    func generateSyntax(with param: Parameter) -> String
}

public extension SyntaxBuildable {
    func generateSyntaxBuilder(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> String {
        let syntax = SourceFileSyntax(
            statements: CodeBlockItemListSyntax {
                itemsBuilder()
            }
        )
        
        return syntax.formatted().description
    }
    
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

public enum ImportModule: String {
    case argumentParser = "ArgumentParser"
    case deadline = "Deadline"
    case foundation = "Foundation"
    case packageDescription = "PackageDescription"
    case postgresNIO = "PostgresNIO"
    case spectreKit = "SpectreKit"
}
