//
//  EB+ComputeFunc.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public extension EvaluatorBuilder {
    struct ComputeFuncBuilder {
        /// Builds the syntax for `computeAggregates()` function
        /// - Parameter phi: The current set of `Phi` parameters
        /// - Returns: A `FunctionDeclSyntax` wrapped in a `MemberBlockItemSyntax`
        ///
        /// Consider the following `E-SQL` query:
        /// ```sql
        /// select cust, count(NY.quant), sum(NJ.quant), sum(CT.quant)
        /// from sales
        /// group by cust; NY, NJ, CT
        /// such that NY.cust = cust and NY.state = 'NY',
        ///           NJ.cust = cust and NJ.state = 'NJ',
        ///           CT.cust = cust and CT.state = 'CT'
        /// ```
        ///
        /// This function returns the syntax for:
        /// ```swift
        /// func computeAggregates(
        ///     on mfStructs: [MFStruct]
        /// ) async throws -> [MFStruct] {
        ///     var output = mfStructs
        ///
        ///     let rows = try await service.query()
        ///
        ///     for try await row in rows.decode(Sales.self) {
        ///         let index = output.findIndex(cust: row.0)
        ///
        ///         if (row.5 == "NJ") {
        ///             output[index].sum_2_quant += Double(row.6)
        ///         }
        ///
        ///         if (row.5 == "CT") {
        ///             output[index].max_3_quant = max(output[index].max_3_quant, Double(row.6))
        ///         }
        ///
        ///         if (row.5 == "NY") {
        ///             output[index].count_1_quant += 1
        ///         }
        ///     }
        ///
        ///     return output
        /// }
        /// ```
        public func buildSyntax(with phi: Phi) -> MemberBlockItemSyntax {
            return MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    // func
                    funcKeyword: .keyword(.func),
                    // computeAggregates
                    name: .identifier("computeAggregates"),
                    // () async throws -> [MFStruct]
                    signature: self.buildFuncSignature(),
                    // Function Body
                    body: self.buildFuncBody(with: phi)
                )
            )
        }
        
        /// Builds the syntax for function parameters, effect specifiers, and return type
        /// - Returns: The syntax as `FunctionSignatureSyntax`
        ///
        /// Regardless of `Phi`, builds the following syntax:
        /// ```swift
        /// (on mfStructs: [MFStruct]) async throws -> [MFStruct]
        /// ```
        private func buildFuncSignature() -> FunctionSignatureSyntax {
            return FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    // (
                    leftParen: .leftParenToken(),
                    // on mfStructs: [MFStruct]
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            firstName: .identifier("on"),
                            secondName: .identifier("mfStructs"),
                            type: ArrayTypeSyntax(
                                element: IdentifierTypeSyntax(
                                    name: .identifier("MFStruct")
                                )
                            )
                        )
                    },
                    // )
                    rightParen: .rightParenToken()
                ),
                effectSpecifiers: FunctionEffectSpecifiersSyntax(
                    // async
                    asyncSpecifier: .keyword(.async),
                    throwsClause: ThrowsClauseSyntax(
                        // throws
                        throwsSpecifier: .keyword(.throws)
                    )
                ),
                returnClause: ReturnClauseSyntax(
                    // ->
                    arrow: .arrowToken(),
                    // [MFStruct]
                    type: ArrayTypeSyntax(
                        element: IdentifierTypeSyntax(
                            name: .identifier("MFStruct")
                        )
                    )
                )
            )
        }
        
        /// Builds the syntax for the function body of the `computeAggregates()` function
        /// - Parameter phi: The current set of `Phi` parameters
        /// - Returns: A `CodeBlockSyntax` containing the whole function body
        ///
        /// For the following `E-SQL` query:
        /// ```sql
        /// select cust, count(NY.quant), sum(NJ.quant), sum(CT.quant)
        /// from sales
        /// group by cust; NY, NJ, CT
        /// such that NY.cust = cust and NY.state = 'NY',
        ///           NJ.cust = cust and NJ.state = 'NJ',
        ///           CT.cust = cust and CT.state = 'CT'
        /// ```
        ///
        /// This function returns the syntax for:
        /// ```swift
        /// var output = mfStructs
        ///
        /// let rows = try await service.query()
        ///
        /// for try await row in rows.decode(Sales.self) {
        ///     let index = output.findIndex(cust: row.0)
        ///
        ///     if (row.5 == "NJ") {
        ///         output[index].sum_2_quant += Double(row.6)
        ///     }
        ///
        ///     if (row.5 == "CT") {
        ///         output[index].max_3_quant = max(output[index].max_3_quant, Double(row.6))
        ///     }
        ///
        ///     if (row.5 == "NY") {
        ///         output[index].count_1_quant += 1
        ///     }
        /// }
        ///
        /// return output
        /// ```
        private func buildFuncBody(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    // var output = mfStructs
                    self.buildOutputDeclSyntax()
                    
                    // let rows = try await service.query()
                    self.buildQueryRowsSyntax()
                    
                    // for try await row in rows.decode(Sales.self) { ... }
                    self.buildDecodeRowsLoopSyntax(with: phi)
                    
                    if let havingPredicate = phi.havingPredicate {
                        // output = output.filter({ ... })
                        self.buildHavingFilterSyntax(havingPredicate)
                    }

                    // return output
                    self.buildReturnSyntax()
                }
            )
        }
        
        /// Build syntax for the declaration for the output variable
        /// - Returns: Returns a `VariableDeclSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// var output = mfStructs
        /// ```
        private func buildOutputDeclSyntax() -> VariableDeclSyntax {
            return VariableDeclSyntax(
                // var
                bindingSpecifier: .keyword(.var),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // output
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("output")
                        ),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            // mfStructs
                            value: DeclReferenceExprSyntax(
                                baseName: .identifier("mfStructs")
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds a variable declaration for fetching querried rows
        /// - Returns: A `VariableDeclSyntax` assigned to the output of a query function
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
        
        /// Builds syntax for a `for` loop that decodes and processes queried rows
        /// - Parameter phi: The current set of `Phi` parameters
        /// - Returns: The for-loop as `ForStmtSyntax`
        ///
        /// For the following `E-SQL` query:
        /// ```sql
        /// select cust, count(NY.quant), sum(NJ.quant), sum(CT.quant)
        /// from sales
        /// group by cust; NY, NJ, CT
        /// such that NY.cust = cust and NY.state = 'NY',
        ///           NJ.cust = cust and NJ.state = 'NJ',
        ///           CT.cust = cust and CT.state = 'CT'
        /// ```
        ///
        /// Builds the following syntax:
        /// ```swift
        /// for try await row in rows.decode(Sales.self) {
        ///     let index = output.findIndex(cust: row.0)
        ///
        ///     if (row.5 == "NJ") {
        ///         output[index].sum_2_quant += Double(row.6)
        ///     }
        ///
        ///     if (row.5 == "CT") {
        ///         output[index].max_3_quant = max(output[index].max_3_quant, Double(row.6))
        ///     }
        ///
        ///     if (row.5 == "NY") {
        ///         output[index].count_1_quant += 1
        ///     }
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
                // Loop Body
                body: self.buildComputeSyntax(with: phi),
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds syntax for the body of the for-loop that deocdes a query
        /// - Parameter phi: The current set of `Phi` parameters
        /// - Returns: A `CodeBlockSyntax`
        ///
        /// For the following `E-SQL` query:
        /// ```sql
        /// select cust, count(NY.quant), sum(NJ.quant), sum(CT.quant)
        /// from sales
        /// group by cust; NY, NJ, CT
        /// such that NY.cust = cust and NY.state = 'NY',
        ///           NJ.cust = cust and NJ.state = 'NJ',
        ///           CT.cust = cust and CT.state = 'CT'
        /// ```
        ///
        /// Builds the following syntax:
        /// ```swift
        /// let index = output.findIndex(cust: row.0)
        ///
        /// if (row.5 == "NJ") {
        ///     output[index].sum_2_quant += Double(row.6)
        /// }
        ///
        /// if (row.5 == "CT") {
        ///     output[index].max_3_quant = max(output[index].max_3_quant, Double(row.6))
        /// }
        ///
        /// if (row.5 == "NY") {
        ///     output[index].count_1_quant += 1
        /// }
        /// ```
        private func buildComputeSyntax(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    // let index = output.findIndex(cust: row.0)
                    self.buildFindIndexSyntax(with: phi.groupByAttributes)
                    
                    let allAggregates = phi.aggregates.groupByVariableId()
                    for index in 0..<allAggregates.count {
                        self.buildAggregateSyntax(for: allAggregates[index], at: index, with: phi)
                    }
                }
            )
        }
        
        /// Builds the `index` constant declaration containing the `MFStruct` for the current row's group-by attribute values
        /// - Parameter groupByAttributes: The group-by attributes to use as parameters
        /// - Returns: Builds a `VariableDeclSyntax`
        ///
        /// For the following `E-SQL` query:
        /// ```sql
        /// select cust, count(NY.quant), sum(NJ.quant), sum(CT.quant)
        /// from sales
        /// group by cust; NY, NJ, CT
        /// such that NY.cust = cust and NY.state = 'NY',
        ///           NJ.cust = cust and NJ.state = 'NJ',
        ///           CT.cust = cust and CT.state = 'CT'
        /// ```
        ///
        /// Builds the following syntax:
        /// ```swift
        /// let index = output.findIndex(cust: row.0)
        /// ```
        ///
        /// For multiple attributes, it builds a syntax like this:
        /// ```swift
        /// let index = output.findIndex(cust: row.0, prod: row.1)
        /// ```
        private func buildFindIndexSyntax(with groupByAttributes: [String]) -> VariableDeclSyntax {
            return VariableDeclSyntax(
                // let
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // index
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("index")
                        ),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                // output.findIndex
                                calledExpression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(
                                        baseName: .identifier("output")
                                    ),
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier("findIndex")
                                    )
                                ),
                                // (
                                leftParen: .leftParenToken(),
                                // cust: row.0 (in the example)
                                arguments: self.buildFindIndexParamSyntax(attributes: groupByAttributes),
                                // )
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the parameters and values for all group-by variables
        /// - Parameter attributes: The group-by attributes to use as parameters
        /// - Returns: The parameter-value pairs as a `LabeledExprListSyntax`
        ///
        /// For the following `E-SQL` query:
        /// ```sql
        /// select cust, count(NY.quant), sum(NJ.quant), sum(CT.quant)
        /// from sales
        /// group by cust; NY, NJ, CT
        /// such that NY.cust = cust and NY.state = 'NY',
        ///           NJ.cust = cust and NJ.state = 'NJ',
        ///           CT.cust = cust and CT.state = 'CT'
        /// ```
        ///
        /// Builds the following syntax:
        /// ```swift
        /// cust: row.0
        /// ```
        ///
        /// In the event of multiple attributes, it builds a syntax like this:
        /// ```swift
        /// cust: row.0, prod: cust.1
        /// ```
        private func buildFindIndexParamSyntax(attributes: [String]) -> LabeledExprListSyntax {
            return LabeledExprListSyntax {
                for index in 0..<attributes.count {
                    let attribute = attributes[index]
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
                        trailingComma: index == attributes.count - 1 ? nil : .commaToken()
                    )
                }
            }
        }
        
        /// Builds an if-statement conditioned on the grouping predicate(s) of an Aggregate
        /// - Parameters:
        ///   - aggregates: An array of ``Aggregate``s all for the same grouping variable
        ///   - index: The index where `aggregates` is located; used to determine spacing
        ///   - phi: The current set of `Phi` parameters
        /// - Returns: Builds an `IfExprSyntax`
        ///
        /// For the following `E-SQL` query:
        /// ```sql
        /// select cust, count(NY.quant), sum(NJ.quant), sum(CT.quant)
        /// from sales
        /// group by cust; NY, NJ, CT
        /// such that NY.cust = cust and NY.state = 'NY',
        ///           NJ.cust = cust and NJ.state = 'NJ',
        ///           CT.cust = cust and CT.state = 'CT'
        /// ```
        ///
        /// Builds the following syntax for the `NJ` grouping variable:
        /// ```swift
        /// if (row.5 == "NJ") {
        ///     output[index].sum_2_quant += Double(row.6)
        /// }
        /// ```
        private func buildAggregateSyntax(for aggregates: [Aggregate], at index: Int, with phi: Phi) -> IfExprSyntax {
            return IfExprSyntax(
                // if
                ifKeyword: .keyword(.if),
                // (...)
                conditions: self.buildAggregateConditionSyntax(for: aggregates[0], with: phi),
                // { ... }
                body: self.buildCalculateBodySyntax(for: aggregates),
                trailingTrivia: index == phi.aggregates.count - 1 ? nil : .newlines(2)
            )
        }
        
        /// Builds a boolean condition based on an ``Aggregate``'s grouping predicate(s)
        /// - Parameters:
        ///   - aggregate: An aggregate to build a condition for
        ///   - phi: The current set of `Phi` parameters
        /// - Returns: The condition as a `ConditionElementListSyntax`
        ///
        /// For the following `E-SQL` query:
        /// ```sql
        /// select cust, count(NY.quant), sum(NJ.quant), sum(CT.quant)
        /// from sales
        /// group by cust; NY, NJ, CT
        /// such that NY.cust = cust and NY.state = 'NY',
        ///           NJ.cust = cust and NJ.state = 'NJ',
        ///           CT.cust = cust and CT.state = 'CT'
        /// ```
        ///
        /// Builds the following syntax for the `NJ` grouping variable:
        /// ```swift
        /// row.5 == "NJ"
        /// ```
        private func buildAggregateConditionSyntax(for aggregate: Aggregate, with phi: Phi) -> ConditionElementListSyntax {
            return ConditionElementListSyntax {
                ConditionElementSyntax(
                    condition: .expression(
                        ExprSyntax(
                            TupleExprSyntax(
                                // (
                                leftParen: .leftParenToken(),
                                // and-seperated condition
                                elements: LabeledExprListSyntax {
                                    LabeledExprSyntax(
                                        expression: self.buildCalculateConditionSyntax(
                                            predicates: phi.groupingVarPredicates.find(for: aggregate.groupingVarId)
                                        )
                                    )
                                },
                                // )
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                )
            }
        }
        
        /// Builds an `&&`-seperated expression based on given predicates
        /// - Parameter predicates: An array of ``Predicate`` for the same grouping variable
        /// - Returns: A `InfixOperatorExprSyntax` for all the predicates
        ///
        /// For the following `E-SQL` query:
        /// ```sql
        /// select cust, count(NY.quant), sum(NJ.quant), sum(CT.quant)
        /// from sales
        /// group by cust; NY, NJ, CT
        /// such that NY.cust = cust and NY.state = 'NY',
        ///           NJ.cust = cust and NJ.state = 'NJ',
        ///           CT.cust = cust and CT.state = 'CT'
        /// ```
        ///
        /// Builds the following syntax for the `NJ` grouping variable:
        /// ```swift
        /// row.5 == "NJ"
        /// ```
        ///
        /// If there were multiple predicates, the following syntax would be built:
        /// ```swift
        /// row.5 == "NJ" && row.6 > 1000
        /// ```
        private func buildCalculateConditionSyntax(predicates: [Predicate]) -> InfixOperatorExprSyntax {
            if predicates.count == 1 {
                return InfixOperatorExprSyntax(
                    leftOperand: predicates[0].value1.syntax,
                    operator: BinaryOperatorExprSyntax(
                        operator: .binaryOperator(predicates[0].operator.swiftEquivalent)
                    ),
                    rightOperand: predicates[0].value2.syntax
                )
                
            } else {
                var rest = predicates
                let last = rest.remove(at: predicates.count - 1)
                
                return InfixOperatorExprSyntax(
                    leftOperand: self.buildCalculateConditionSyntax(predicates: rest),
                    operator: BinaryOperatorExprSyntax(
                        operator: .binaryOperator("&&")
                    ),
                    rightOperand: InfixOperatorExprSyntax(
                        leftOperand: last.value1.syntax,
                        operator: BinaryOperatorExprSyntax(
                            operator: .binaryOperator(last.operator.swiftEquivalent)
                        ),
                        rightOperand: last.value2.syntax
                    )
                )
            }
        }
        
        /// Builds a container for an `IfExprSyntax`, containing the assignment syntax for an aggregate
        /// - Parameter aggregates: An array of aggregates to update
        /// - Returns: Builds the syntax as a `CodeBlockSyntax`
        ///
        /// For the following `E-SQL` query:
        /// ```sql
        /// select cust, count(NY.quant), sum(NJ.quant), sum(CT.quant)
        /// from sales
        /// group by cust; NY, NJ, CT
        /// such that NY.cust = cust and NY.state = 'NY',
        ///           NJ.cust = cust and NJ.state = 'NJ',
        ///           CT.cust = cust and CT.state = 'CT'
        /// ```
        ///
        /// Builds the following syntax for the `NJ` grouping variable:
        /// ```swift
        /// output[index].sum_2_quant += Double(row.6)
        /// ```
        ///
        /// A notable exception is average calculations. They are calculated by tracking the sum and count of elements.
        ///
        /// If we were calculate for `avg(NJ.quant)` instead:
        /// ```swift
        /// output[index].avg_2_quant.sum += Double(row.6)
        /// output[index].avg_2_quant.count += 1
        /// ```
        private func buildCalculateBodySyntax(for aggregates: [Aggregate]) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    for aggregate in aggregates {
                        if aggregate.function != .avg {
                            self.buildCalculateUpdateSyntax(for: aggregate)
                        } else {
                            self.buildCalculateUpdateSyntax(for: aggregate, overwrite: .sum)
                            self.buildCalculateUpdateSyntax(for: aggregate, overwrite: .count)
                        }
                    }
                }
            )
        }
        
        /// Builds a single assignment syntax for an aggregate
        /// - Parameters:
        ///   - aggregate: An aggreate to build syntax for
        ///   - overwrite: Overwrites `aggregate.function`, but maintains the other properties of `aggregate`. Particularly used for averages.
        /// - Returns: Builds a `InfixOperatorExprSyntax` based on an `Aggregate`
        ///
        /// For the following `E-SQL` query:
        /// ```sql
        /// select cust, count(NY.quant), sum(NJ.quant), sum(CT.quant)
        /// from sales
        /// group by cust; NY, NJ, CT
        /// such that NY.cust = cust and NY.state = 'NY',
        ///           NJ.cust = cust and NJ.state = 'NJ',
        ///           CT.cust = cust and CT.state = 'CT'
        /// ```
        ///
        /// Builds the following syntax for the `NJ` grouping variable:
        /// ```swift
        /// output[index].sum_2_quant += Double(row.6)
        /// ```
        ///
        /// If `overwrite` exists, `aggregate.function` will be ignored in favor of `overwrite`. Suppose `overwrite = .max`:
        /// ```swift
        /// output[index].sum_2_quant = max(output[index].sum_2_quant, Double(row.6))
        /// ```
        private func buildCalculateUpdateSyntax(
            for aggregate: Aggregate,
            overwrite: AggregateFunction? = nil
        ) -> InfixOperatorExprSyntax {
            return InfixOperatorExprSyntax(
                // output[index].sum_2_quant (in example)
                leftOperand: self.buildAggregateMemberAccessSyntax(aggregate: aggregate, overwrite: overwrite),
                // =
                operator: aggregate.function.operatorSyntax,
                // Double(row.6) (in example)
                rightOperand: aggregate.updateSyntax(overwrite: overwrite)
            )
        }
        
        /// Builds the left-side of a single assignment syntax for an aggregate
        /// - Parameters:
        ///   - aggregate: An aggreate to build syntax for
        ///   - overwrite: Overwrites `aggregate.function`, but maintains the other properties of `aggregate`. Particularly used for averages.
        /// - Returns: Builds a `MemberAccessExprSyntax`  for the aggregate
        ///
        /// Suppose the aggregate is `sum_2_quant`.
        ///
        /// If `overwrite` is `nil`, returns the syntax for:
        /// ```swift
        /// output[index].sum_2_quant
        /// ```
        ///
        /// If `overwrite` is, say, `count`, returns the syntax for:
        /// ```swift
        /// output[index].sum_2_quant.count
        /// ```
        private func buildAggregateMemberAccessSyntax(
            aggregate: Aggregate,
            overwrite: AggregateFunction? = nil
        ) -> MemberAccessExprSyntax {
            if let overwrite = overwrite {
                return MemberAccessExprSyntax(
                    base: self.buildAggregateMemberAccessSyntax(aggregate: aggregate),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier(overwrite.rawValue)
                    )
                )
                
            } else {
                return MemberAccessExprSyntax(
                    // output[index]
                    base: SubscriptCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(
                            baseName: .identifier("output")
                        ),
                        arguments: LabeledExprListSyntax {
                            LabeledExprSyntax(
                                expression: DeclReferenceExprSyntax(
                                    baseName: .identifier("index")
                                )
                            )
                        }
                    ),
                    // sum_2_quant (in example)
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier(aggregate.name)
                    )
                )
            }
        }
        
        /// Builds the syntax to filter based on a having predicate
        /// - Parameter havingPredicate: Some ``Predicate``
        /// - Precondition: Assumes a having predicate exists
        /// - Returns: Builds an `InfixOperatorExprSyntax` containing a `filter` expression
        ///
        /// For the following `ESQL` query:
        /// ```sql
        /// select cust, sum(x.quant), sum(y.quant), sum(z.quant)
        /// from sales
        /// group by cust; NY, NJ, CT
        /// such that NY.cust = cust and NY.state = 'NY',
        ///           NJ.cust = cust and NJ.state = 'NJ',
        ///           CT.cust = cust and CT.state = 'CT'
        /// having sum(NY.quant) > 2 * sum(NJ.quant) or avg(NY.quant) > avg(CT.quant);
        /// ```
        ///
        /// Builds the following syntax:
        /// ```swift
        /// output = output.filter({ $0.sum_1_quant > 2.0 * $0.sum_2_quant || $0.avg_1_quant > $0.avg_3_quant })
        /// ```
        private func buildHavingFilterSyntax(_ havingPredicate: PredicateValue) -> InfixOperatorExprSyntax {
            return InfixOperatorExprSyntax(
                // output
                leftOperand: DeclReferenceExprSyntax(
                    baseName: .identifier("output")
                ),
                // =
                operator: AssignmentExprSyntax(),
                rightOperand: FunctionCallExprSyntax(
                    // output.filter
                    calledExpression: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(
                            baseName: .identifier("output")
                        ),
                        declName: DeclReferenceExprSyntax(
                            baseName: .identifier("filter")
                        )
                    ),
                    // (
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax {
                        LabeledExprSyntax(
                            expression: ClosureExprSyntax(
                                // {
                                leftBrace: .leftBraceToken(),
                                // $0.sum_1_quant > 2.0 * $0.sum_2_quant || $0.avg_1_quant > $0.avg_3_quant (in example)
                                statements: CodeBlockItemListSyntax {
                                    havingPredicate.syntax
                                },
                                // }
                                rightBrace: .rightBraceToken()
                            )
                        )
                    },
                    // )
                    rightParen: .rightParenToken(),
                    trailingTrivia: .newlines(2)
                )
            )
        }
        
        /// Builds syntax to return the output variable
        /// - Returns: A `ReturnStmtSyntax`
        ///
        /// Builds the syntax for:
        /// ```swift
        /// return output
        /// ```
        private func buildReturnSyntax() -> ReturnStmtSyntax {
            return ReturnStmtSyntax(
                expression: DeclReferenceExprSyntax(
                    baseName: .identifier("output")
                )
            )
        }
    }
}
