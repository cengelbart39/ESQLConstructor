//
//  EB+EvaluateFunc.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public extension EvaluatorBuilder {
    struct EvaluateFuncBuilder {
        /// Builds the `MemberBlockItemSyntax` containing the `evaluate()` function
        ///
        /// Builds the following syntax:
        /// ```swift
        /// func evaluate() async throws {
        ///     try await withThrowingTaskGroup(of: Void.self) { taskGroup in
        ///         taskGroup.addTask {
        ///             await self.service.client.run()
        ///         }
        ///
        ///         var mfStructs = try await self.populateMFStruct()
        ///         mfStructs = try await self.computeAggregates(on: mfStructs)
        ///
        ///         ResultPrinter().print(mfStructs)
        ///
        ///         taskGroup.cancelAll()
        ///     }
        /// }
        /// ```
        public func buildSyntax() -> MemberBlockItemSyntax {
            return MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    // evaluate
                    name: .identifier("evaluate"),
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
                    // { ... }
                    body: self.buildBodySyntax(),
                    trailingTrivia: .newlines(2)
                )
            )
        }
        
        /// Builds the syntax for the body of the `evaluate()` function
        ///
        /// Builds the following syntax:
        /// ```swift
        /// try await withThrowingTaskGroup(of: Void.self) { taskGroup in
        ///     taskGroup.addTask {
        ///         await self.service.client.run()
        ///     }
        ///
        ///     var mfStructs = try await self.populateMFStruct()
        ///     mfStructs = try await self.computeAggregates(on: mfStructs)
        ///
        ///     ResultPrinter().print(mfStructs)
        ///
        ///     taskGroup.cancelAll()
        /// }
        /// ```
        private func buildBodySyntax() -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    // try
                    TryExprSyntax(
                        // await
                        expression: AwaitExprSyntax(
                            expression: FunctionCallExprSyntax(
                                // withThrowingTaskGroup
                                calledExpression: DeclReferenceExprSyntax(
                                    baseName: .identifier("withThrowingTaskGroup")
                                ),
                                // (
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax {
                                    // of: Void.self
                                    LabeledExprSyntax(
                                        label: .identifier("of"),
                                        colon: .colonToken(),
                                        expression: MemberAccessExprSyntax(
                                            base: DeclReferenceExprSyntax(
                                                baseName: .identifier("Void")
                                            ),
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .keyword(.self)
                                            )
                                        )
                                    )
                                },
                                // )
                                rightParen: .rightParenToken(),
                                trailingClosure: ClosureExprSyntax(
                                    // {
                                    leftBrace: .leftBraceToken(),
                                    // taskGroup in
                                    signature: ClosureSignatureSyntax(
                                        parameterClause: .simpleInput(
                                            ClosureShorthandParameterListSyntax {
                                                ClosureShorthandParameterSyntax(
                                                    name: .identifier("taskGroup")
                                                )
                                            }
                                        )
                                    ),
                                    // body
                                    statements: CodeBlockItemListSyntax {
                                        // taskGroup.addTask { ... }
                                        self.buildRunTaskSyntax()
                                        
                                        // var mfStructs = try await self.populateMFStruct()
                                        self.buildPopulateSyntax()
                                        
                                        // mfStructs = try await self.computeAggregates(on: mfStructs)
                                        self.buildComputeSyntax()
                                        
                                        // for row in mfStructs { ... }
                                        self.buildPrintSyntax()
                                        
                                        // taskGroup.cancelAll()
                                        self.buildTaskCancelSyntax()
                                    },
                                    // }
                                    rightBrace: .rightBraceToken()
                                )
                            )
                        )
                    )
                }
            )
        }
        
        /// Builds the syntax for adding the `PostgresClient.run()` as a task
        ///
        /// Builds the following syntax:
        /// ```swift
        /// taskGroup.addTask {
        ///     await self.service.client.run()
        /// }
        /// ```
        private func buildRunTaskSyntax() -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
                // taskGroup.addTask
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier("taskGroup")
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("addTask")
                    )
                ),
                arguments: LabeledExprListSyntax { },
                trailingClosure: ClosureExprSyntax(
                    // {
                    leftBrace: .leftBraceToken(),
                    statements: CodeBlockItemListSyntax {
                        // await
                        AwaitExprSyntax(
                            expression: FunctionCallExprSyntax(
                                // self.service.client.run
                                calledExpression: MemberAccessExprSyntax(
                                    base: MemberAccessExprSyntax(
                                        base: MemberAccessExprSyntax(
                                            base: DeclReferenceExprSyntax(
                                                baseName: .keyword(.self)
                                            ),
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier("service")
                                            )
                                        ),
                                        declName: DeclReferenceExprSyntax(
                                            baseName: .identifier("client")
                                        )
                                    ),
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier("run")
                                    )
                                ),
                                // (
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax { },
                                // )
                                rightParen: .rightParenToken()
                            )
                        )
                    },
                    // }
                    rightBrace: .rightBraceToken()
                ),
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the syntax for populating the `MFStruct` array
        ///
        /// Builds the following syntax:
        /// ```swift
        /// var mfStructs = try await self.populateMFStruct()
        /// ```
        private func buildPopulateSyntax() -> VariableDeclSyntax {
            return VariableDeclSyntax(
                // var
                bindingSpecifier: .keyword(.var),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // mfStructs
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("mfStructs")
                        ),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            // try
                            value: TryExprSyntax(
                                // await
                                expression: AwaitExprSyntax(
                                    expression: FunctionCallExprSyntax(
                                        // self.populateMFStruct
                                        calledExpression: MemberAccessExprSyntax(
                                            base: DeclReferenceExprSyntax(
                                                baseName: .keyword(.self)
                                            ),
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier("populateMFStruct")
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
                        )
                    )
                }
            )
        }
        
        /// Builds the syntax for calculating the aggregates
        ///
        /// Builds the following syntax:
        /// ```swift
        /// mfStructs = try await self.computeAggregates(on: mfStructs)
        /// ```
        private func buildComputeSyntax() -> InfixOperatorExprSyntax {
            return InfixOperatorExprSyntax(
                // mfStructs
                leftOperand: DeclReferenceExprSyntax(
                    baseName: .identifier("mfStructs")
                ),
                // =
                operator: AssignmentExprSyntax(),
                // try
                rightOperand: TryExprSyntax(
                    // await
                    expression: AwaitExprSyntax(
                        expression: FunctionCallExprSyntax(
                            // self.computeAggregates
                            calledExpression: MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(
                                    baseName: .keyword(.self)
                                ),
                                declName: DeclReferenceExprSyntax(
                                    baseName: .identifier("computeAggregates")
                                )
                            ),
                            // (
                            leftParen: .leftParenToken(),
                            arguments: LabeledExprListSyntax {
                                // on: mfStructs
                                LabeledExprSyntax(
                                    label: .identifier("on"),
                                    colon: .colonToken(),
                                    expression: DeclReferenceExprSyntax(
                                        baseName: .identifier("mfStructs")
                                    )
                                )
                            },
                            // )
                            rightParen: .rightParenToken()
                        )
                    )
                ),
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the syntax for printing the computed results
        ///
        /// Builds the following syntax:
        /// ```swift
        /// ResultPrinter().print(mfStructs)
        /// ```
        private func buildPrintSyntax() -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
                calledExpression: MemberAccessExprSyntax(
                    base: FunctionCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(
                            baseName: .identifier("ResultPrinter")
                        ),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax { },
                        rightParen: .rightParenToken()
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("print")
                    )
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier("mfStructs")
                        )
                    )
                },
                rightParen: .rightParenToken(),
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the syntax for cancelling the `PostgresClient.run()` task
        ///
        /// Builds the following syntax:
        /// ```swift
        /// taskGroup.cancelAll()
        /// ```
        private func buildTaskCancelSyntax() -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
                // taskGroup.cancelAll
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier("taskGroup")
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("cancelAll")
                    )
                ),
                // (
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax { },
                // )
                rightParen: .rightParenToken()
            )
        }
    }
}
