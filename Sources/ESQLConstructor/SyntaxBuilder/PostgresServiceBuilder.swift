//
//  PostgresServiceBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/26/24.
//

import SwiftSyntax

/**
 A syntax builder and generate that creates an output varation of `PostgresService`
 
 This produces the below code. Note that the `PostgresClient.Configuration` can vary due to input, where both `password` and `database` can be `nil`
 ```swift
 import PostgresNIO
 import Deadline

 struct PostgresService: Sendable {
     let client: PostgresClient

     init() {
         let config = PostgresClient.Configuration(host: "localhost", port: 5432, username: "username", password: "password", database: "database", tls: .disable)
         self.client = PostgresClient(configuration: config)
     }

     func query(_ query: PostgresQuery, until seconds: Int) async throws -> PostgresRowSequence {
         return try await withDeadline(until: .now + .seconds(seconds)) {
             try await self.client.query(query)
         }
     }

     func connectAndRun(operation: () async throws -> Void) async throws {
         try await withThrowingTaskGroup(of: Void.self) { taskGroup in
             taskGroup.addTask {
                 await self.client.run()
             }
             try await operation()
             taskGroup.cancelAll()
         }
     }
 }
 ```
 */
struct PostgresServiceBuilder {
    /**
     Defines the necessary imports
     ```swift
     import PostgresNIO
     import Deadline
     ```
     */
    private func buildImportSyntax() -> [CodeBlockItemSyntax] {
        return [
            CodeBlockItemSyntax(
                item: CodeBlockItemSyntax.Item(
                    ImportDeclSyntax(
                        path: ImportPathComponentListSyntax {
                            ImportPathComponentSyntax(name: .identifier("PostgresNIO"))
                        }
                    )
                )
            ),
            
            CodeBlockItemSyntax(
                item: CodeBlockItemSyntax.Item(
                    ImportDeclSyntax(
                        path: ImportPathComponentListSyntax {
                            ImportPathComponentSyntax(name: .identifier("Deadline"))
                        },
                        trailingTrivia: .newlines(2)
                    )
                )
            )
        ]
    }
    
    /**
     Builds the syntax for the whole `PostgresService` struct
     - Parameter service: A local version of ``PostgresService`` for database credentials
     */
    private func buildStructSyntax(with service: PostgresService) -> CodeBlockItemSyntax {
        CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                StructDeclSyntax(
                    name: .identifier("PostgresService"),
                    inheritanceClause: InheritanceClauseSyntax(
                        inheritedTypes: InheritedTypeListSyntax {
                            InheritedTypeSyntax(
                                type: IdentifierTypeSyntax(
                                    name: .identifier("Sendable")
                                )
                            )
                        }
                    ),
                    memberBlock: MemberBlockSyntax(
                        members: MemberBlockItemListSyntax {
                            self.buildFieldSyntax()
                            
                            self.buildInitSyntax(with: service)
                            
                            self.buildQueryFuncSyntax()
                        }
                    )
                )
            )
        )
    }
    
    private func buildFieldSyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("client")
                        ),
                        typeAnnotation: TypeAnnotationSyntax(
                            type: IdentifierTypeSyntax(
                                name: "PostgresClient"
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    private func buildInitSyntax(with service: PostgresService) -> MemberBlockItemSyntax {
        MemberBlockItemSyntax(
            decl: InitializerDeclSyntax(
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        parameters: FunctionParameterListSyntax { }
                    )
                ),
                body: self.buildInitBodySyntax(with: service),
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    private func buildInitBodySyntax(with service: PostgresService) -> CodeBlockSyntax {
        return CodeBlockSyntax(
            statements: CodeBlockItemListSyntax {
                self.buildInitBodyConfigSyntax(with: service)
                
                self.buildInitBodyClientSyntax()
            }
        )
    }
    
    private func buildInitBodyConfigSyntax(with service: PostgresService) -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                VariableDeclSyntax(
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
                                        LabeledExprSyntax(
                                            label: .identifier("host"),
                                            colon: .colonToken(),
                                            expression: StringLiteralExprSyntax(
                                                openingQuote: .stringQuoteToken(),
                                                segments: StringLiteralSegmentListSyntax {
                                                    StringSegmentSyntax(
                                                        content: .stringSegment(service.host)
                                                    )
                                                },
                                                closingQuote: .stringQuoteToken()
                                            ),
                                            trailingComma: .commaToken()
                                        )
                                        
                                        LabeledExprSyntax(
                                            label: .identifier("port"),
                                            colon: .colonToken(),
                                            expression: IntegerLiteralExprSyntax(
                                                literal: .integerLiteral("\(service.port)")
                                            ),
                                            trailingComma: .commaToken()
                                        )
                                        
                                        LabeledExprSyntax(
                                            label: .identifier("username"),
                                            colon: .colonToken(),
                                            expression: StringLiteralExprSyntax(
                                                openingQuote: .stringQuoteToken(),
                                                segments: StringLiteralSegmentListSyntax {
                                                    StringSegmentSyntax(
                                                        content: .stringSegment(service.username)
                                                    )
                                                },
                                                closingQuote: .stringQuoteToken()
                                            ),
                                            trailingComma: .commaToken()
                                        )
                                        
                                        self.optionalLabelExprSyntax(for: "password", as: service.password)
                                        
                                        self.optionalLabelExprSyntax(for: "database", as: service.database)
                                        
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
            )
        )
    }
    
    private func optionalLabelExprSyntax(for field: String, as str: String?) -> LabeledExprSyntax {
        if let str = str {
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
                trailingComma: .commaToken()
            )
            
        } else {
            return LabeledExprSyntax(
                label: .identifier(field),
                colon: .colonToken(),
                expression: NilLiteralExprSyntax(),
                trailingComma: .commaToken()
            )
        }
    }
    
    private func buildInitBodyClientSyntax() -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                InfixOperatorExprSyntax(
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
            )
        )
    }
    
    private func buildQueryFuncSyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: FunctionDeclSyntax(
                name: .identifier("query"),
                signature: self.buildQueryFuncSignatureSyntax(),
                body: self.buildQueryFuncBodySyntax(),
                trailingTrivia: .newlines(2)
            )
        )
    }
    
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
    
    private func buildQueryFuncBodySyntax() -> CodeBlockSyntax {
        return CodeBlockSyntax(
            statements: CodeBlockItemListSyntax {
                CodeBlockItemSyntax(
                    item: CodeBlockItemSyntax.Item(
                        ReturnStmtSyntax(
                            expression: TryExprSyntax(
                                expression: AwaitExprSyntax(
                                    expression: FunctionCallExprSyntax(
                                        calledExpression: DeclReferenceExprSyntax(
                                            baseName: .identifier("withDeadline")
                                        ),
                                        leftParen: .leftParenToken(),
                                        arguments: LabeledExprListSyntax {
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
                                        },
                                        rightParen: .rightParenToken(),
                                        trailingClosure: self.buildQueryFuncBodyClosureSyntax()
                                    )
                                )
                            )
                        )
                    )
                )
            }
        )
    }
    
    private func buildQueryFuncBodyClosureSyntax() -> ClosureExprSyntax {
        return ClosureExprSyntax(
            statements: CodeBlockItemListSyntax {
                CodeBlockItemSyntax(
                    item: CodeBlockItemSyntax.Item(
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
                    )
                )
            }
        )
    }
        
    /**
     Generates the syntax for the output version of `PostgresService`
     - Parameter service: A ``PostgresService`` that contains the database credentials
     - Returns: The formatted code for the output
     */
    public func generateSyntax(with service: PostgresService) -> String {
        let imports = self.buildImportSyntax()
        let serviceStruct = self.buildStructSyntax(with: service)
        
        let syntax = SourceFileSyntax(
            statements: CodeBlockItemListSyntax {
                imports[0]
                imports[1]
                serviceStruct
            }
        )
        
        return syntax.formatted().description
    }
}
