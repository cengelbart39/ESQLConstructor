//
//  EB+PopulateFunc.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public extension EvaluatorBuilder {
    struct PopulateFuncBuilder {
        /// Builds the syntax for `Evaluator`'s `populateMFStruct()` function
        /// - Parameter phi: Phi operator used in decoding
        /// - Returns: The syntax as a `MemberBlockItemSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// func populateMFStruct() async throws -> [MFStruct] {
        ///     var mfStructs = [MFStruct]()
        ///
        ///     let rows = try await service.query()
        ///
        ///     for try await row in rows.decode(Sales.self) {
        ///         if !mfStructs.exists(cust: row.0) {
        ///             let mfStruct = MFStruct(
        ///                 cust: row.0,
        ///                 avg_1_quant: Average(),
        ///                 sum_2_quant: .zero,
        ///                 max_3_quant: Double(Int.min)
        ///             )
        ///
        ///             mfStructs.append(mfStruct)
        ///         }
        ///     }
        ///
        ///     return mfStructs
        /// }
        ///
        /// ```
        public func buildSyntax(with phi: Phi) -> MemberBlockItemSyntax {
            return MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    // func populateMFStruct
                    name: .identifier("populateMFStruct"),
                    signature: FunctionSignatureSyntax(
                        // ()
                        parameterClause: FunctionParameterClauseSyntax(
                            parameters: FunctionParameterListSyntax { }
                        ),
                        // async throws
                        effectSpecifiers: FunctionEffectSpecifiersSyntax(
                            asyncSpecifier: .keyword(.async),
                            throwsClause: ThrowsClauseSyntax(
                                throwsSpecifier: .keyword(.throws)
                            )
                        ),
                        // -> [MFStruct]
                        returnClause: ReturnClauseSyntax(
                            type: ArrayTypeSyntax(
                                element: IdentifierTypeSyntax(
                                    name: .identifier("MFStruct")
                                )
                            )
                        )
                    ),
                    body: CodeBlockSyntax(
                        statements: CodeBlockItemListSyntax {
                            // var mfStructs = [MFStruct]()
                            self.buildMFStructArrDeclSyntax()
                            
                            // let rows = try await service.query()
                            self.buildQueryRowsSyntax()
                            
                            // for try await row in rows.decode(Sales.self) { ... }
                            self.buildDecodeRowsLoopSyntax(with: phi)
                            
                            // return mfStructs
                            ReturnStmtSyntax(
                                expression: DeclReferenceExprSyntax(
                                    baseName: .identifier("mfStructs")
                                )
                            )
                        }
                    ),
                    trailingTrivia: .newlines(2)
                )
            )
        }
        
        /// Builds the syntax for the declaration of an empty `MFStruct` array
        /// - Returns: The syntax as a `VariableDeclSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// var mfStructs = [MFStruct]()
        /// ```
        private func buildMFStructArrDeclSyntax() -> VariableDeclSyntax {
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
                            // [MFStruct]()
                            value: FunctionCallExprSyntax(
                                calledExpression: ArrayExprSyntax(
                                    elements: ArrayElementListSyntax {
                                        ArrayElementSyntax(
                                            expression: DeclReferenceExprSyntax(
                                                baseName: .identifier("MFStruct")
                                            )
                                        )
                                    }
                                ),
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax { },
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
        private func buildQueryRowsSyntax() -> VariableDeclSyntax {
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
        /// Builds the following syntax:
        /// ```swift
        /// for try await row in rows.decode(Sales.self) {
        ///     if !mfStructs.exists(cust: row.0) {
        ///         let mfStruct = MFStruct(
        ///             cust: row.0,
        ///             avg_1_quant: Average(),
        ///             sum_2_quant: .zero,
        ///             max_3_quant: Double(Int.min)
        ///         )
        ///
        ///         mfStructs.append(mfStruct)
        ///     }
        /// }
        ///
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
                body: self.buildIfExistsSyntax(with: phi),
                // }
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the syntax to create and append new `MFStruct` if it doesn't exist in an array
        /// - Parameter phi: Source of projected value information
        /// - Returns: The syntax as a `ExpressionStmtSyntax` wrapped in a `CodeBlockSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// if !mfStructs.exists(cust: row.0) {
        ///     let mfStruct = MFStruct(
        ///         cust: row.0,
        ///         avg_1_quant: Average(),
        ///         sum_2_quant: .zero,
        ///         max_3_quant: Double(Int.min)
        ///     )
        ///
        ///     mfStructs.append(mfStruct)
        /// }
        /// ```
        private func buildIfExistsSyntax(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    ExpressionStmtSyntax(
                        // if
                        expression: IfExprSyntax(
                            // Condition
                            conditions: ConditionElementListSyntax {
                                self.buildIfConditionSyntax(with: phi)
                            },
                            // Body for if True
                            body: self.buildIfBodySyntax(with: phi)
                        )
                    )
                }
            )
        }
        
        /// Builds the syntax of the condition for an `IfExprSyntax`
        /// - Parameter phi: Source of projected value information
        /// - Returns: The syntax as a `ConditionElementSyntax`
        ///
        /// Builds the following syntax if the only group-by attribute is `cust`:
        /// ```swift
        /// !mfStructs.exists(cust: row.0)
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
                                        baseName: .identifier("mfStructs")
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
        
        /// Builds the syntax of the body of an `IfExprSyntax`
        /// - Parameter phi: Source of projected value information
        /// - Returns: The syntax as a `CodeBlockSyntax`
        ///
        /// Builds the following syntax if the projected attributes are `cust`, `avg_1_quant`,
        /// `sum_2_quant`, and `max_3_quant`:
        /// ```swift
        /// let mfStruct = MFStruct(
        ///     cust: row.0,
        ///     avg_1_quant: Average(),
        ///     sum_2_quant: .zero,
        ///     max_3_quant: Double(Int.min)
        /// )
        ///
        /// mfStructs.append(mfStruct)
        /// ```
        private func buildIfBodySyntax(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    // let mfStruct = MFStruct(...)
                    self.buildMFStructDeclSyntax(with: phi)
                    
                    // mfStructs.append(mfStruct)
                    self.buildMFStructArrAppendSyntax()
                }
            )
        }
        
        /// Builds the syntax for the creation of a `MFStruct` based on decoded data
        /// - Parameter phi: Source of projected value information
        /// - Returns: The syntax as a `VariableDeclSyntax`
        ///
        /// Builds the following syntax if the projected attributes are `cust`, `avg_1_quant`,
        /// `sum_2_quant`, and `max_3_quant`:
        /// ```swift
        /// let mfStruct = MFStruct(
        ///     cust: row.0,
        ///     avg_1_quant: Average(),
        ///     sum_2_quant: .zero,
        ///     max_3_quant: Double(Int.min)
        /// )
        /// ```
        private func buildMFStructDeclSyntax(with phi: Phi) -> VariableDeclSyntax {
            return VariableDeclSyntax(
                // let
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // mfStruct
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("mfStruct")
                        ),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                // MFStruct
                                calledExpression: DeclReferenceExprSyntax(
                                    baseName: .identifier("MFStruct")
                                ),
                                // (
                                leftParen: .leftParenToken(),
                                // Parameter Call
                                arguments: LabeledExprListSyntax {
                                    let count = phi.groupByAttributes.count + phi.aggregates.count
                                    
                                    // Loop for Group-By Attributes
                                    for index in 0..<phi.groupByAttributes.count {
                                        let attribute = phi.groupByAttributes[index]
                                        
                                        // In format of:
                                        // <attribute>: row.<num>
                                        LabeledExprSyntax(
                                            leadingTrivia: .newline,
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
                                            trailingComma: index == count - 1 ? nil : .commaToken(),
                                            trailingTrivia: index == count - 1 ? .newline : nil
                                        )
                                    }
                                    
                                    // Loop for Aggregate Functions
                                    for index in 0..<phi.aggregates.count {
                                        let aggregate = phi.aggregates[index]
                                        
                                        // In format of:
                                        // <name>: <defaultValue>
                                        LabeledExprSyntax(
                                            leadingTrivia: .newline,
                                            label: .identifier(aggregate.name),
                                            colon: .colonToken(),
                                            expression: aggregate.function.defaultValueSyntax,
                                            trailingComma: index == phi.aggregates.count - 1 ? nil : .commaToken(),
                                            trailingTrivia: index == phi.aggregates.count - 1 ? .newline : nil
                                        )
                                    }
                                },
                                // )
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the syntax for append of the newly created `MFStruct`
        /// - Returns: The syntax as a `FunctionCallExprSyntax`
        ///
        /// Builds the following syntax if the projected attributes are `cust`, `avg_1_quant`,
        /// `sum_2_quant`, and `max_3_quant`:
        /// ```swift
        /// mfStructs.append(mfStruct)
        /// ```
        private func buildMFStructArrAppendSyntax() -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
                // mfStructs.append
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier("mfStructs")
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("append")
                    )
                ),
                // (
                leftParen: .leftParenToken(),
                // mfStruct
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier("mfStruct")
                        )
                    )
                },
                // )
                rightParen: .rightParenToken()
            )
        }
    }
}
