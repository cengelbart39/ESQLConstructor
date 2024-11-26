//
//  PSB+QueryFunc.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public extension PostgresServiceBuilder {
    struct QueryFuncBuilder {
        /// Builds a `MemberBlockItemSyntax` containing the `query()` function
        /// - Returns: The syntax for the `query()` function
        ///
        /// Builds the following syntax:
        /// ```swift
        /// func query() async throws -> PostgresRowSequence {
        ///     return try await withDeadline(until: .now + .seconds(15)) {
        ///         try await self.client.query("select * from sales")
        ///     }
        /// }
        /// ```
        public func buildSyntax() -> MemberBlockItemSyntax {
            return MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    // func
                    funcKeyword: .keyword(.func),
                    // query
                    name: .identifier("query"),
                    // () async throws -> PostgresRowSequence
                    signature: self.buildQueryFuncSignatureSyntax(),
                    // { ... }
                    body: self.buildQueryFuncBodySyntax(),
                    trailingTrivia: .newlines(2)
                )
            )
        }
        
        /// Builds the `FunctionSignatureSyntax` for the `query(_:until:)` function
        ///
        /// Builds the following syntax:
        /// ```swift
        /// () async throws -> PostgresRowSequence
        /// ```
        private func buildQueryFuncSignatureSyntax() -> FunctionSignatureSyntax {
            return FunctionSignatureSyntax(
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
                ),
                // -> PostgresRowSequence
                returnClause: ReturnClauseSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier("PostgresRowSequence")
                    )
                )
            )
        }
        
        /// Builds the `CodeBlockSyntax` for the body of the `query()` function
        ///
        /// Builds the following syntax:
        /// ```swift
        /// return try await withDeadline(until: .now + .seconds(15)) {
        ///     try await self.client.query("select * from sales")
        /// }
        /// ```
        private func buildQueryFuncBodySyntax() -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    ReturnStmtSyntax(
                        // return
                        returnKeyword: .keyword(.return),
                        expression: TryExprSyntax(
                            // try
                            tryKeyword: .keyword(.try),
                            expression: AwaitExprSyntax(
                                // await
                                awaitKeyword: .keyword(.await),
                                expression: FunctionCallExprSyntax(
                                    // withDeadline
                                    calledExpression: DeclReferenceExprSyntax(
                                        baseName: .identifier("withDeadline")
                                    ),
                                    // (
                                    leftParen: .leftParenToken(),
                                    // until: .now + .seconds(15)
                                    arguments: self.buildWithDeadlineArgumentSyntax(),
                                    // )
                                    rightParen: .rightParenToken(),
                                    // { try await self.client.query("select * from sales") }
                                    trailingClosure: self.buildWithDeadlineClosureSyntax()
                                )
                            )
                        )
                    )
                }
            )
        }
        
        /// Builds the arguments of the `withDeadline(until:operation:)` function
        ///
        /// Builds the following syntax:
        /// ```swift
        /// until: .now + .seconds(15)
        /// ```
        private func buildWithDeadlineArgumentSyntax() -> LabeledExprListSyntax {
            return LabeledExprListSyntax {
                LabeledExprSyntax(
                    // until
                    label: .identifier("until"),
                    colon: .colonToken(),
                    // :
                    expression: InfixOperatorExprSyntax(
                        // .now
                        leftOperand: MemberAccessExprSyntax(
                            declName: DeclReferenceExprSyntax(
                                baseName: .identifier("now")
                            )
                        ),
                        // +
                        operator: BinaryOperatorExprSyntax(
                            operator: .binaryOperator("+")
                        ),
                        // .seconds(15)
                        rightOperand: FunctionCallExprSyntax(
                            calledExpression: MemberAccessExprSyntax(
                                declName: DeclReferenceExprSyntax(
                                    baseName: .identifier("seconds")
                                )
                            ),
                            leftParen: .leftParenToken(),
                            arguments: LabeledExprListSyntax {
                                LabeledExprSyntax(
                                    expression: IntegerLiteralExprSyntax(15)
                                )
                            },
                            rightParen: .rightParenToken()
                        )
                    )
                )
            }
        }
        
        /// Builds the closure of the `withDeadline(until:operation:)` function
        ///
        /// Builds the following syntax:
        /// ```swift
        /// { try await self.client.query("select * from sales") }
        /// ```
        private func buildWithDeadlineClosureSyntax() -> ClosureExprSyntax {
            return ClosureExprSyntax(
                // {
                leftBrace: .leftBraceToken(),
                statements: CodeBlockItemListSyntax {
                    // try
                    TryExprSyntax(
                        // await
                        expression: AwaitExprSyntax(
                            expression: FunctionCallExprSyntax(
                                // client.query
                                calledExpression: MemberAccessExprSyntax(
                                    base: MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax(
                                            baseName: .keyword(.self)
                                        ),
                                        declName: DeclReferenceExprSyntax(
                                            baseName: .identifier("client")
                                        )
                                    ),
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier("query")
                                    )
                                ),
                                // (
                                leftParen: .leftParenToken(),
                                // "select * from sales*
                                arguments: LabeledExprListSyntax {
                                    LabeledExprSyntax(
                                        expression: StringLiteralExprSyntax(
                                            openingQuote: .stringQuoteToken(),
                                            segments: StringLiteralSegmentListSyntax {
                                                StringSegmentSyntax(
                                                    content: .stringSegment("select * from sales")
                                                )
                                            },
                                            closingQuote: .stringQuoteToken()
                                        )
                                    )
                                },
                                // )
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                },
                // }
                rightBrace: .rightBraceToken()
            )
        }
    }
}
