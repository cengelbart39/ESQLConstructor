//
//  MainBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/27/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public struct MainBuilder: SyntaxBuildable {
    public typealias Parameter = Void
    
    /// Builds a `StructDeclSyntax` for the `@main` function of the generated utility
    /// - Returns: The `StructDeclSyntax` for the `@main` function
    ///
    /// Builds the following syntax:
    /// ```swift
    /// @main
    /// struct ESQLEvaluator: AsyncParsableCommand {
    ///     static let configuration = CommandConfiguration(
    ///         abstract: "A utility that runs the result of a ESQL Phi Operator. Constructed by ESQLConstructor.",
    ///         version: "1.0.0"
    ///     )
    ///
    ///     func run() async throws {
    ///         let service = PostgresService()
    ///         let evaluator = Evaluator(service: service)
    ///         try await evaluator.evaluate()
    ///     }
    /// }
    /// ```
    func buildStructSyntax() -> StructDeclSyntax {
        return StructDeclSyntax(
            attributes: AttributeListSyntax {
                AttributeSyntax(
                    attributeName: IdentifierTypeSyntax(
                        name: .identifier("main")
                    ),
                    trailingTrivia: .newline
                )
            },
            name: .identifier("ESQLEvaluator"),
            inheritanceClause: InheritanceClauseSyntax(
                inheritedTypes: InheritedTypeListSyntax {
                    InheritedTypeSyntax(
                        type: IdentifierTypeSyntax(
                            name: .identifier("AsyncParsableCommand")
                        )
                    )
                }
            ),
            memberBlock: MemberBlockSyntax(
                members: MemberBlockItemListSyntax {
                    self.buildCommandConfigSyntax()
                    RunBuilder().buildFunc()
                }
            )
        )
    }
    
    /// Builds a `MemberBlockItemSyntax` for the command configuration
    /// - Returns: Syntax for `ESQLEvaluator`'s `CommandConfiguration`
    ///
    /// Builds syntax for the following:
    /// ```swift
    /// static let configuration = CommandConfiguration(
    ///     abstract: "A utility that runs the result of a ESQL Phi Operator. Constructed by ESQLConstructor.",
    ///     version: "1.0.0"
    /// )
    /// ```
    private func buildCommandConfigSyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: VariableDeclSyntax(
                modifiers: DeclModifierListSyntax {
                    DeclModifierSyntax(
                        name: .keyword(.static)
                    )
                },
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("configuration")
                        ),
                        initializer: InitializerClauseSyntax(
                            value: FunctionCallExprSyntax(
                                calledExpression: DeclReferenceExprSyntax(
                                    baseName: .identifier("CommandConfiguration")
                                ),
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax {
                                    LabeledExprSyntax(
                                        leadingTrivia: .newline,
                                        label: .identifier("abstract"),
                                        colon: .colonToken(),
                                        expression: StringLiteralExprSyntax(
                                            openingQuote: .stringQuoteToken(),
                                            segments: StringLiteralSegmentListSyntax {
                                                StringSegmentSyntax(
                                                    content: .stringSegment("A utility that runs the result of a ESQL Phi Operator. Constructed by ESQLConstructor.")
                                                )
                                            },
                                            closingQuote: .stringQuoteToken()
                                        ),
                                        trailingComma: .commaToken()
                                    )
                                    
                                    LabeledExprSyntax(
                                        leadingTrivia: .newline,
                                        label: .identifier("version"),
                                        colon: .colonToken(),
                                        expression: StringLiteralExprSyntax(
                                            openingQuote: .stringQuoteToken(),
                                            segments: StringLiteralSegmentListSyntax {
                                                StringSegmentSyntax(
                                                    content: .stringSegment("1.0.0")
                                                )
                                            },
                                            closingQuote: .stringQuoteToken()
                                        ),
                                        trailingTrivia: .newline
                                    )
                                },
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    public func generateSyntax(with param: Void = Void()) -> String {
        let import1 = self.buildImportSyntax(.argumentParser)
        let import2 = self.buildImportSyntax(.foundation, leadingTrivia: .newlines(2))
        
        let mainStruct = self.buildStructSyntax()
        
        return self.generateSyntaxBuilder {
            import1
            import2
            mainStruct
        }
    }
}
