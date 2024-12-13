//
//  EB+EvaluateFunc.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//  CWID: 10467610
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
        ///         var results = [MFStruct]()
        ///
        ///         let rows = try await service.query()
        ///
        ///         for try await row in rows.decode(Sales.self) {
        ///             if !results.exists(cust: row.0) {
        ///                 self.populate(&results, with: row)
        ///             }
        ///
        ///             self.computeAggregates(on: &results, using: row)
        ///         }
        ///
        ///         ResultPrinter().print(mfStructs)
        ///
        ///         taskGroup.cancelAll()
        ///     }
        /// }
        /// ```
        ///
        /// If `phi` contains a having predicate, the following line will appear before printing the result:
        /// ```swift
        /// self.applyHavingClause(to: &results)
        /// ```
        public func buildSyntax(with phi: Phi) -> MemberBlockItemSyntax {
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
                    body: self.buildBodySyntax(with: phi),
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
        ///     for try await row in rows.decode(Sales.self) {
        ///         if !results.exists(cust: row.0) {
        ///             self.populate(&results, with: row)
        ///         }
        ///
        ///         self.computeAggregates(on: &results, using: row)
        ///     }
        ///
        ///     ResultPrinter().print(mfStructs)
        ///
        ///     taskGroup.cancelAll()
        /// }
        /// ```
        ///
        /// If `phi` contains a having predicate, the following line will appear before printing the result:
        /// ```swift
        /// self.applyHavingClause(to: &results)
        /// ```
        private func buildBodySyntax(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    TryExprSyntax(
                        // try
                        tryKeyword: .keyword(.try),
                        expression: AwaitExprSyntax(
                            // await
                            awaitKeyword: .keyword(.await),
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
                                        
                                        // var results = [MFStruct]()
                                        self.buildResultArraySyntax()
                                        
                                        // let rows = try await service.query()
                                        self.buildQuerySyntax()
                                        
                                        // for try await row in rows.decode(Sales.self) { ... }
                                        self.buildDecodeRowsLoopSyntax(with: phi)
                                        
                                        if phi.havingPredicate != nil {
                                            // self.applyHavingClause(to: &results)
                                            self.buildHavingFunctionCall()
                                        }
                                        
                                        // ResultPrinter().print(results)
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
        
        /// Builds the syntax to declare an empty `MFStruct` array
        /// - Returns: Builds syntax as a `VariableDeclSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// var results = [MFStruct]()
        /// ```
        private func buildResultArraySyntax() -> VariableDeclSyntax {
            return VariableDeclSyntax(
                // var
                bindingSpecifier: .keyword(.var),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // results
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("results")
                        ),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                calledExpression: ArrayExprSyntax(
                                    // [
                                    leftSquare: .leftSquareToken(),
                                    elements: ArrayElementListSyntax {
                                        // MFStruct
                                        ArrayElementSyntax(
                                            expression: DeclReferenceExprSyntax(
                                                baseName: .identifier("MFStruct")
                                            )
                                        )
                                    },
                                    // ]
                                    rightSquare: .rightSquareToken()
                                ),
                                // (
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax { },
                                // )
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the syntax to query and recieve the rows from the database
        /// - Returns: The syntax as a `VariableDeclSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// let rows = try await service.query()
        /// ```
        private func buildQuerySyntax() -> VariableDeclSyntax {
            return VariableDeclSyntax(
                // let
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // rows
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("rows")
                        ),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            // try
                            value: TryExprSyntax(
                                // await
                                expression: AwaitExprSyntax(
                                    expression: FunctionCallExprSyntax(
                                        // service.query
                                        calledExpression: MemberAccessExprSyntax(
                                            base: DeclReferenceExprSyntax(
                                                baseName: .identifier("service")
                                            ),
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier("query")
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
                },
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the syntax to decode and process the rows from the database
        /// - Parameter phi: Source of projected value information
        /// - Returns: The syntax as a `ForStmtSyntax`
        ///
        /// If the only group-by attribute is `cust`, builds the following syntax:
        /// ```swift
        /// for try await row in rows.decode(Sales.self) {
        ///     if !results.exists(cust: row.0) {
        ///         self.populate(&results, with: row)
        ///     }
        ///
        ///     self.computeAggregates(on: &results, using: row)
        /// }
        /// ```
        private func buildDecodeRowsLoopSyntax(with phi: Phi) -> ForStmtSyntax {
            return ForStmtSyntax(
                // for
                forKeyword: .keyword(.for),
                // try
                tryKeyword: .keyword(.try),
                // await
                awaitKeyword: .keyword(.await),
                // row
                pattern: IdentifierPatternSyntax(
                    identifier: .identifier("row")
                ),
                // in
                inKeyword: .keyword(.in),
                sequence: FunctionCallExprSyntax(
                    // rows.decode
                    calledExpression: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(
                            baseName: .identifier("rows")
                        ),
                        declName: DeclReferenceExprSyntax(
                            baseName: .identifier("decode")
                        )
                    ),
                    // (
                    leftParen: .leftParenToken(),
                    // Sales.self
                    arguments: LabeledExprListSyntax {
                        LabeledExprSyntax(
                            expression: MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(
                                    baseName: .identifier("Sales")
                                ),
                                declName: DeclReferenceExprSyntax(
                                    baseName: .keyword(.self)
                                )
                            )
                        )
                    },
                    // )
                    rightParen: .rightParenToken()
                ),
                // {
                // For Statement Body
                body: self.buildLoopBodySyntax(with: phi),
                // }
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the body of the decoding for loop
        /// - Parameter phi: Current set of Phi parameters
        /// - Returns: The syntax as a `CodeBlockSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// if !results.exists(cust: row.0) {
        ///     self.populate(&results, with: row)
        /// }
        ///
        /// self.computeAggregates(on: &results, using: row)
        /// ```
        private func buildLoopBodySyntax(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    // if !results.exists(...) { ... }
                    self.buildIfExistsSyntax(with: phi)
                    
                    // self.computeAggregates(on: &results, using: row)
                    self.buildComputeFunctionCall()
                }
            )
        }
        
        /// Builds the syntax to create and append new `MFStruct` if it doesn't exist in an array
        /// - Parameter phi: Source of projected value information
        /// - Returns: The syntax as a `ExpressionStmtSyntax` wrapped in a `CodeBlockSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// if !results.exists(cust: row.0) {
        ///     self.populate(&results, with: row)
        /// }
        /// ```
        private func buildIfExistsSyntax(with phi: Phi) -> ExpressionStmtSyntax {
            return ExpressionStmtSyntax(
                // if
                expression: IfExprSyntax(
                    // Condition
                    conditions: ConditionElementListSyntax {
                        self.buildIfConditionSyntax(with: phi)
                    },
                    // Body for if True
                    body: CodeBlockSyntax(
                        statements: CodeBlockItemListSyntax {
                            FunctionCallExprSyntax(
                                calledExpression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(
                                        baseName: .keyword(.self)
                                    ),
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier("populate")
                                    )
                                ),
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax {
                                    LabeledExprSyntax(
                                        expression: InOutExprSyntax(
                                            ampersand: .prefixAmpersandToken(),
                                            expression: DeclReferenceExprSyntax(
                                                baseName: .identifier("results")
                                            )
                                        ),
                                        trailingComma: .commaToken()
                                    )
                                    
                                    LabeledExprSyntax(
                                        label: .identifier("with"),
                                        colon: .colonToken(),
                                        expression: DeclReferenceExprSyntax(
                                            baseName: .identifier("row")
                                        )
                                    )
                                },
                                rightParen: .rightParenToken()
                            )
                        }
                    )
                ),
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the syntax of the condition for an `IfExprSyntax`
        /// - Parameter phi: Source of projected value information
        /// - Returns: The syntax as a `ConditionElementSyntax`
        ///
        /// Builds the following syntax if the only group-by attribute is `cust`:
        /// ```swift
        /// !results.exists(cust: row.0)
        /// ```
        private func buildIfConditionSyntax(with phi: Phi) -> ConditionElementSyntax {
            return ConditionElementSyntax(
                condition: .expression(
                    ExprSyntax(
                        PrefixOperatorExprSyntax(
                            // ! (not)
                            operator: .prefixOperator("!"),
                            expression: FunctionCallExprSyntax(
                                // mfStructs.exist
                                calledExpression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(
                                        baseName: .identifier("results")
                                    ),
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier("exists")
                                    )
                                ),
                                // (
                                leftParen: .leftParenToken(),
                                // cust: row.0 (in the example)
                                arguments: LabeledExprListSyntax {
                                    // Loop through Group-By Attributes
                                    // Assign proper parameter name and decoded value
                                    for index in 0..<phi.groupByAttributes.count {
                                        let attribute = phi.groupByAttributes[index]
                                        
                                        LabeledExprSyntax(
                                            label: .identifier(attribute),
                                            colon: .colonToken(),
                                            expression: MemberAccessExprSyntax(
                                                base: DeclReferenceExprSyntax(
                                                    baseName: .identifier("row")
                                                ),
                                                declName: DeclReferenceExprSyntax(
                                                    baseName: .identifier(SalesColumn(rawValue: attribute)!.tupleNum)
                                                )
                                            ),
                                            trailingComma: index == phi.groupByAttributes.count - 1 ? nil : .commaToken()
                                        )
                                    }
                                },
                                // )
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                )
            )
        }
        
        /// Builds the syntax to compute/update the aggregates using a specific row
        /// - Returns: The syntax as a `FunctionCallExprSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// self.computeAggregates(on: &results, using: row)
        /// ```
        private func buildComputeFunctionCall() -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
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
                    // on: &results
                    LabeledExprSyntax(
                        label: .identifier("on"),
                        colon: .colonToken(),
                        expression: InOutExprSyntax(
                            ampersand: .prefixAmpersandToken(),
                            expression: DeclReferenceExprSyntax(
                                baseName: .identifier("results")
                            )
                        ),
                        // ,
                        trailingComma: .commaToken()
                    )
                    
                    // using: row
                    LabeledExprSyntax(
                        label: .identifier("using"),
                        colon: .colonToken(),
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier("row")
                        )
                    )
                },
                // )
                rightParen: .rightParenToken()
            )
        }
        
        /// Builds the syntax to apply the having predicate to the resulting `MFStruct` array
        /// - Note: While this function in and of itself doesn't rely on the existance of a
        /// having predicate, its presence in the outputted package assumes it exists.
        /// - Returns: Syntax as a `FunctionCallExprSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// self.applyHavingClause(to: &results)
        /// ```
        private func buildHavingFunctionCall() -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .keyword(.self)
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("applyHavingClause")
                    )
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        label: .identifier("to"),
                        colon: .colonToken(),
                        expression: InOutExprSyntax(
                            ampersand: .prefixAmpersandToken(),
                            expression: DeclReferenceExprSyntax(
                                baseName: .identifier("results")
                            )
                        )
                    )
                },
                rightParen: .rightParenToken(),
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the syntax for printing the computed results
        ///
        /// Builds the following syntax:
        /// ```swift
        /// ResultPrinter().print(results)
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
                            baseName: .identifier("results")
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
