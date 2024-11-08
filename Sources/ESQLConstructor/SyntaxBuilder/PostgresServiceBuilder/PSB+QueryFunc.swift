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
        /// Builds a `MemberBlockItemSyntax` containing the `query(_:until:)` function
        /// - Returns: The syntax for the `query(_:until:)` function
        ///
        /// Builds the following syntax:
        /// ```swift
        /// func query(_ query: PostgresQuery, until seconds: Int) async throws -> PostgresRowSequence {
        ///     return try await withDeadline(until: .now + .seconds(seconds)) {
        ///         try await self.client.query(query)
        ///     }
        /// }
        /// ```
        public func buildSyntax() -> MemberBlockItemSyntax {
            return MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    name: .identifier("query"),
                    signature: self.buildQueryFuncSignatureSyntax(),
                    body: self.buildQueryFuncBodySyntax(),
                    trailingTrivia: .newlines(2)
                )
            )
        }
        
        /// Builds the `FunctionSignatureSyntax` for the `query(_:until:)` function
        ///
        /// Builds the following syntax:
        /// ```swift
        /// (_ query: PostgresQuery, until seconds: Int) async throws -> PostgresRowSequence
        /// ```
        private func buildQueryFuncSignatureSyntax() -> FunctionSignatureSyntax {
            return FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    leftParen: .leftParenToken(),
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            firstName: .wildcardToken(),
                            secondName: .identifier("query"),
                            type: IdentifierTypeSyntax(
                                name: .identifier("PostgresQuery")
                            ),
                            trailingComma: .commaToken()
                        )
                        
                        FunctionParameterSyntax(
                            firstName: .identifier("until"),
                            secondName: .identifier("seconds"),
                            type: IdentifierTypeSyntax(
                                name: .identifier("Int")
                            )
                        )
                    },
                    rightParen: .rightParenToken()
                ),
                effectSpecifiers: FunctionEffectSpecifiersSyntax(
                    asyncSpecifier: .keyword(.async),
                    throwsClause: ThrowsClauseSyntax(
                        throwsSpecifier: .keyword(.throws)
                    )
                ),
                returnClause: ReturnClauseSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier("PostgresRowSequence")
                    )
                )
            )
        }
        
        /// Builds the `CodeBlockSyntax` for the body of the `query(:until:)` function
        ///
        /// Builds the following syntax:
        /// ```swift
        /// return try await withDeadline(until: .now + .seconds(seconds)) {
        ///     try await self.client.query(query)
        /// }
        /// ```
        private func buildQueryFuncBodySyntax() -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    ReturnStmtSyntax(
                        expression: TryExprSyntax(
                            expression: AwaitExprSyntax(
                                expression: FunctionCallExprSyntax(
                                    calledExpression: DeclReferenceExprSyntax(
                                        baseName: .identifier("withDeadline")
                                    ),
                                    leftParen: .leftParenToken(),
                                    arguments: self.buildWithDeadlineArgumentSyntax(),
                                    rightParen: .rightParenToken(),
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
        /// until: .now + .seconds(seconds)
        /// ```
        private func buildWithDeadlineArgumentSyntax() -> LabeledExprListSyntax {
            return LabeledExprListSyntax {
                LabeledExprSyntax(
                    label: .identifier("until"),
                    colon: .colonToken(),
                    expression: InfixOperatorExprSyntax(
                        leftOperand: MemberAccessExprSyntax(
                            declName: DeclReferenceExprSyntax(
                                baseName: .identifier("now")
                            )
                        ),
                        operator: BinaryOperatorExprSyntax(
                            operator: .binaryOperator("+")
                        ),
                        rightOperand: FunctionCallExprSyntax(
                            calledExpression: MemberAccessExprSyntax(
                                declName: DeclReferenceExprSyntax(
                                    baseName: .identifier("seconds")
                                )
                            ),
                            leftParen: .leftParenToken(),
                            arguments: LabeledExprListSyntax {
                                LabeledExprSyntax(
                                    expression: DeclReferenceExprSyntax(
                                        baseName: .identifier("seconds")
                                    )
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
        /// { try await self.client.query(query) }
        /// ```
        private func buildWithDeadlineClosureSyntax() -> ClosureExprSyntax {
            return ClosureExprSyntax(
                statements: CodeBlockItemListSyntax {
                    TryExprSyntax(
                        expression: AwaitExprSyntax(
                            expression: FunctionCallExprSyntax(
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
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax {
                                    LabeledExprSyntax(
                                        expression: DeclReferenceExprSyntax(
                                            baseName: .identifier("query")
                                        )
                                    )
                                },
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                }
            )
        }
    }
}
