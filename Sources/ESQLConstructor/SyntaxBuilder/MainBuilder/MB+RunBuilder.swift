//
//  MB+RunBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public extension MainBuilder {
    struct RunBuilder {
        /// Builds a `MemberBlockItemSyntax` for the `run()` function
        /// - Returns: Syntax for `ESQLEvaluator`'s `run()` function
        ///
        /// Builds syntax for following:
        /// ```swift
        /// func run() async throws {
        ///     let service = PostgresService()
        ///     let evaluator = Evaluator(service: service)
        ///     try await evaluator.evaluate()
        /// }
        /// ```
        public func buildFunc() -> MemberBlockItemSyntax {
            MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    // func
                    funcKeyword: .keyword(.func),
                    // run
                    name: .identifier("run"),
                    signature: FunctionSignatureSyntax(
                        // ()
                        parameterClause: FunctionParameterClauseSyntax(
                            leftParen: .leftParenToken(),
                            parameters: FunctionParameterListSyntax { },
                            rightParen: .rightParenToken()
                        ),
                        // async throws
                        effectSpecifiers: FunctionEffectSpecifiersSyntax(
                            asyncSpecifier: .keyword(.async),
                            throwsClause: ThrowsClauseSyntax(
                                throwsSpecifier: .keyword(.throws)
                            )
                        )
                    ),
                    body: CodeBlockSyntax(
                        // {
                        leftBrace: .leftBraceToken(),
                        statements: CodeBlockItemListSyntax {
                            // let service = PostgresService()
                            self.buildPostgresServiceDeclSyntax()
                            
                            // let evaluator = Evaluator(service: service)
                            self.buildEvaluatorDeclSyntax()
                            
                            // try await evaluator.evaluate()
                            self.buildEvaluateExprSyntax()
                        },
                        // }
                        rightBrace: .rightBraceToken()
                    )
                )
            )
        }
        
        /// Builds a `VariableDeclSyntax` for the constant declaration of type `PostgresService`
        /// - Returns: Syntax for the `run()` function's constant declaration of type `PostgresService`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// let service = PostgresService()
        /// ```
        private func buildPostgresServiceDeclSyntax() -> VariableDeclSyntax {
            return VariableDeclSyntax(
                // let
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // service
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("service")
                        ),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                // PostgresService
                                calledExpression: DeclReferenceExprSyntax(
                                    baseName: .identifier("PostgresService")
                                ),
                                // (
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax { },
                                // )
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                }
            )
        }
        
        /// Builds a `VariableDeclSyntax` for the constant declaration of type `Evaluator`
        /// - Returns: Syntax for the `run()` function's constant declaration of type `Evaluator`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// let evaluator = Evaluator(service: service)
        /// ```
        private func buildEvaluatorDeclSyntax() -> VariableDeclSyntax {
            return VariableDeclSyntax(
                // let
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // evaluator
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("evaluator")
                        ),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                // Evaluator
                                calledExpression: DeclReferenceExprSyntax(
                                    baseName: .identifier("Evaluator")
                                ),
                                // (
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax {
                                    // service: service
                                    LabeledExprSyntax(
                                        label: .identifier("service"),
                                        colon: .colonToken(),
                                        expression: DeclReferenceExprSyntax(
                                            baseName: .identifier("service")
                                        )
                                    )
                                },
                                // )
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                }
            )
        }
        
        /// Builds a `TryExprSyntax` for the evaluation function call
        /// - Returns: Syntax for the `run()` function's constant evaluation function call
        ///
        /// Builds the following syntax:
        /// ```swift
        /// try await evaluator.evaluate()
        /// ```
        private func buildEvaluateExprSyntax() -> TryExprSyntax {
            return TryExprSyntax(
                // try
                tryKeyword: .keyword(.try),
                expression: AwaitExprSyntax(
                    // await
                    awaitKeyword: .keyword(.await),
                    expression: FunctionCallExprSyntax(
                        // evaluator.evaluate
                        calledExpression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(
                                baseName: .identifier("evaluator")
                            ),
                            declName: DeclReferenceExprSyntax(
                                baseName: .identifier("evaluate")
                            )
                        ),
                        // (
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax { },
                        // )
                        rightParen: .rightParenToken()
                    )
                )
            )
        }
    }
}
