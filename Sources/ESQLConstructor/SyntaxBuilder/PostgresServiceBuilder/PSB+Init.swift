//
//  PSB+Init.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public extension PostgresServiceBuilder {
    struct InitBuilder {
        /// Build a `MemberBlockItemSyntax` containing the `init()`
        /// - Parameter service: The ``PostgresService`` with database credentials
        /// - Returns: The full `init` syntax
        ///
        /// Builds the following syntax:
        /// ```swift
        /// init() {
        ///     let config = PostgresClient.Configuration(host: "localhost", port: 5432, username: "postgres", password: nil, database: nil, tls: .disable)
        ///     self.client = PostgresClient(configuration: config)
        /// }
        /// ```
        public func buildSyntax(with service: PostgresService) -> MemberBlockItemSyntax {
            MemberBlockItemSyntax(
                decl: InitializerDeclSyntax(
                    signature: FunctionSignatureSyntax(
                        parameterClause: FunctionParameterClauseSyntax(
                            parameters: FunctionParameterListSyntax { }
                        )
                    ),
                    body: CodeBlockSyntax(
                        statements: CodeBlockItemListSyntax {
                            self.buildBodyConfigSyntax(with: service)
                            self.buildBodyClientSyntax()
                        }
                    ),
                    trailingTrivia: .newlines(2)
                )
            )
        }
        
        /// Builds a `VariableDeclSyntax` for the declaration of database credentials
        /// - Parameter service: A ``PostgresService`` containing database credentials
        /// - Returns: A `PostgresClient.Configuration` with `service`'s database credentials
        ///
        /// Builds the following syntax:
        /// ```swift
        /// let config = PostgresClient.Configuration(host: "localhost", port: 5432, username: "postgres", password: "040839", database: nil, tls: .disable)
        /// ```
        private func buildBodyConfigSyntax(with service: PostgresService) -> VariableDeclSyntax {
            return VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("config")
                        ),
                        initializer: InitializerClauseSyntax(
                            value: FunctionCallExprSyntax(
                                calledExpression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(
                                        baseName: .identifier("PostgresClient")
                                    ),
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier("Configuration")
                                    )
                                ),
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax {
                                    self.nilableLabelExprSyntax(for: "host", as: service.host, trailingToken: .commaToken())
                                    
                                    self.nilableLabelExprSyntax(for: "port", as: String(service.port), trailingToken: .commaToken())
                                    
                                    self.nilableLabelExprSyntax(for: "username", as: service.username, trailingToken: .commaToken())
                                    
                                    self.nilableLabelExprSyntax(for: "password", as: service.password, trailingToken: .commaToken())
                                    
                                    self.nilableLabelExprSyntax(for: "database", as: service.database, trailingToken: .commaToken())
                                    
                                    LabeledExprSyntax(
                                        label: .identifier("tls"),
                                        colon: .colonToken(),
                                        expression: MemberAccessExprSyntax(
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier("disable")
                                            )
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
        
        /// Builds a `LabeledExprSyntax` that can be a `String`, `Int`, or `nil` depending on the property
        /// - Parameters:
        ///   - field: The name of the parameter
        ///   - str: The value of the parameter passed as a `String` or `nil`
        ///   - trailingToken: A trailing token, if any
        /// - Returns: The appropriate `LabelExprSyntax` containing a `String`, `Int`, or `nil` expression
        ///
        /// Builds syntax in the following format:
        /// ```swift
        /// host: <str>
        /// ```
        private func nilableLabelExprSyntax(
            for field: String,
            as str: String?,
            trailingToken: TokenSyntax? = nil
        ) -> LabeledExprSyntax {
            if let str = str {
                if let num = Int(str) {
                    return LabeledExprSyntax(
                        label: .identifier(field),
                        colon: .colonToken(),
                        expression: IntegerLiteralExprSyntax(
                            literal: .integerLiteral("\(num)")
                        ),
                        trailingComma: trailingToken
                    )
                    
                } else {
                    return LabeledExprSyntax(
                        label: .identifier(field),
                        colon: .colonToken(),
                        expression: StringLiteralExprSyntax(
                            openingQuote: .stringQuoteToken(),
                            segments: StringLiteralSegmentListSyntax {
                                StringSegmentSyntax(
                                    content: .stringSegment(str)
                                )
                            },
                            closingQuote: .stringQuoteToken()
                        ),
                        trailingComma: trailingToken
                    )
                }
                
            } else {
                return LabeledExprSyntax(
                    label: .identifier(field),
                    colon: .colonToken(),
                    expression: NilLiteralExprSyntax(),
                    trailingComma: trailingToken
                )
            }
        }
        
        /// Builds a `InfixOperatorExprSyntax` for the declaration of the `PostgresClient`
        /// - Returns: The syntax for the assignment of a `PostgresClient` using a pre-defined configuration
        ///
        /// Builds the following syntax:
        /// ```swift
        /// self.client = PostgresClient(configuration: config)
        /// ```
        private func buildBodyClientSyntax() -> InfixOperatorExprSyntax {
            return InfixOperatorExprSyntax(
                leftOperand: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .keyword(.self)
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("client")
                    )
                ),
                operator: AssignmentExprSyntax(),
                rightOperand: FunctionCallExprSyntax(
                    calledExpression: DeclReferenceExprSyntax(
                        baseName: .identifier("PostgresClient")
                    ),
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax {
                        LabeledExprSyntax(
                            label: .identifier("configuration"),
                            colon: .colonToken(),
                            expression: DeclReferenceExprSyntax(
                                baseName: .identifier("config")
                            )
                        )
                    },
                    rightParen: .rightParenToken()
                )
                
            )
        }
    }
}
