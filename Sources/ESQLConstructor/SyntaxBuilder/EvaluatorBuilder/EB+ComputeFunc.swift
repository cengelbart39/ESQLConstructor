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
        public func buildSyntax(with phi: Phi) -> MemberBlockItemSyntax {
            return MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    name: .identifier("computeAggregates"),
                    signature: self.buildFuncSignature(),
                    body: self.buildFuncBody(with: phi)
                )
            )
        }
        
        private func buildFuncSignature() -> FunctionSignatureSyntax {
            return FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
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
                    }
                ),
                effectSpecifiers: FunctionEffectSpecifiersSyntax(
                    asyncSpecifier: .keyword(.async),
                    throwsClause: ThrowsClauseSyntax(
                        throwsSpecifier: .keyword(.throws)
                    )
                ),
                returnClause: ReturnClauseSyntax(
                    type: ArrayTypeSyntax(
                        element: IdentifierTypeSyntax(
                            name: .identifier("MFStruct")
                        )
                    )
                )
            )
        }
        
        private func buildFuncBody(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    self.buildOutputDeclSyntax()
                    
                    self.buildQueryRowsSyntax()
                    
                    self.buildDecodeRowsLoopSyntax(with: phi)
                    
                    if let havingPredicate = phi.havingPredicate {
                        self.buildHavingFilterSyntax(havingPredicate)
                    }

                    self.buildReturnSyntax()
                }
            )
        }
        
        private func buildOutputDeclSyntax() -> VariableDeclSyntax {
            return VariableDeclSyntax(
                bindingSpecifier: .keyword(.var),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("output")
                        ),
                        initializer: InitializerClauseSyntax(
                            value: DeclReferenceExprSyntax(
                                baseName: .identifier("mfStructs")
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        }
        
        private func buildQueryRowsSyntax() -> VariableDeclSyntax {
            return VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("rows")
                        ),
                        initializer: InitializerClauseSyntax(
                            value: TryExprSyntax(
                                expression: AwaitExprSyntax(
                                    expression: FunctionCallExprSyntax(
                                        calledExpression: MemberAccessExprSyntax(
                                            base: DeclReferenceExprSyntax(
                                                baseName: .identifier("service")
                                            ),
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier("query")
                                            )
                                        ),
                                        leftParen: .leftParenToken(),
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
                                                ),
                                                trailingComma: .commaToken()
                                            )
                                            
                                            LabeledExprSyntax(
                                                label: .identifier("until"),
                                                colon: .colonToken(),
                                                expression: IntegerLiteralExprSyntax(
                                                    literal: .integerLiteral("15")
                                                )
                                            )
                                        },
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
        
        private func buildDecodeRowsLoopSyntax(with phi: Phi) -> ForStmtSyntax {
            return ForStmtSyntax(
                forKeyword: .keyword(.for),
                tryKeyword: .keyword(.try),
                awaitKeyword: .keyword(.await),
                pattern: IdentifierPatternSyntax(
                    identifier: .identifier("row")
                ),
                sequence: FunctionCallExprSyntax(
                    calledExpression: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(
                            baseName: .identifier("rows")
                        ),
                        declName: DeclReferenceExprSyntax(
                            baseName: .identifier("decode")
                        )
                    ),
                    leftParen: .leftParenToken(),
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
                    rightParen: .rightParenToken()
                ),
                body: self.buildComputeSyntax(with: phi),
                trailingTrivia: .newlines(2)
            )
        }

        private func buildComputeSyntax(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    self.buildFindIndexSyntax(with: phi.groupByAttributes)
                    
                    let aggregates = phi.aggregates
                    for index in 0..<aggregates.count {
                        self.buildAggregateSyntax(for: aggregates[index], at: index, with: phi)
                    }
                }
            )
        }
        
        private func buildFindIndexSyntax(with groupByAttributes: [String]) -> VariableDeclSyntax {
            return VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("index")
                        ),
                        initializer: InitializerClauseSyntax(
                            value: FunctionCallExprSyntax(
                                calledExpression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(
                                        baseName: .identifier("output")
                                    ),
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier("findIndex")
                                    )
                                ),
                                leftParen: .leftParenToken(),
                                arguments: self.buildFindIndexParamSyntax(attributes: groupByAttributes),
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        }
        
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
        
        private func buildAggregateSyntax(for aggregate: Aggregate, at index: Int, with phi: Phi) -> IfExprSyntax {
            return IfExprSyntax(
                conditions: self.buildAggregateConditionSyntax(for: aggregate, with: phi),
                body: CodeBlockSyntax(
                    statements: CodeBlockItemListSyntax {
                        if aggregate.function != .avg {
                            InfixOperatorExprSyntax(
                                leftOperand: MemberAccessExprSyntax(
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
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier(aggregate.name)
                                    )
                                ),
                                operator: self.buildCalculateOperationSyntax(aggregate: aggregate.function),
                                rightOperand: self.buildCalculateRightOperandSyntax(aggregate: aggregate)
                            )
                        } else {
                            InfixOperatorExprSyntax(
                                leftOperand: MemberAccessExprSyntax(
                                    base: MemberAccessExprSyntax(
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
                                        declName: DeclReferenceExprSyntax(
                                            baseName: .identifier(aggregate.name)
                                        )
                                    ),
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier("sum")
                                    )
                                ),
                                operator: self.buildCalculateOperationSyntax(aggregate: .sum),
                                rightOperand: self.buildCalculateRightOperandSyntax(aggregate: aggregate, overwrite: .sum)
                            )
                            
                            InfixOperatorExprSyntax(
                                leftOperand: MemberAccessExprSyntax(
                                    base: MemberAccessExprSyntax(
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
                                        declName: DeclReferenceExprSyntax(
                                            baseName: .identifier(aggregate.name)
                                        )
                                    ),
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier("count")
                                    )
                                ),
                                operator: self.buildCalculateOperationSyntax(aggregate: .count),
                                rightOperand: self.buildCalculateRightOperandSyntax(aggregate: aggregate, overwrite: .count)
                            )
                        }
                    }
                ),
                trailingTrivia: index == phi.aggregates.count - 1 ? nil : .newlines(2)
            )
        }
        
        private func buildAggregateConditionSyntax(for aggregate: Aggregate, with phi: Phi) -> ConditionElementListSyntax {
            return ConditionElementListSyntax {
                ConditionElementSyntax(
                    condition: .expression(
                        ExprSyntax(
                            TupleExprSyntax(
                                elements: LabeledExprListSyntax {
                                    LabeledExprSyntax(
                                        expression: self.buildCalculateConditionSyntax(
                                            predicates: phi.groupingVarPredicates.find(
                                                for: aggregate.groupingVarId
                                            ),
                                            for: SalesColumn(rawValue: aggregate.attribute)!.tupleNum
                                        )
                                    )
                                }
                            )
                        )
                    )
                )
            }
        }
        
        private func buildCalculateConditionSyntax(predicates: [Predicate], for item: String) -> InfixOperatorExprSyntax {
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
                    leftOperand: self.buildCalculateConditionSyntax(predicates: rest, for: item),
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
        
        private func buildCalculateOperationSyntax(aggregate: AggregateFunction) -> any ExprSyntaxProtocol {
            if aggregate == .max || aggregate == .min {
                return AssignmentExprSyntax()
                
            } else {
                return BinaryOperatorExprSyntax(
                    operator: .binaryOperator("+=")
                )
            }
        }
        
        private func buildCalculateBodySyntax(for aggregate: Aggregate) -> CodeBlockItemListSyntax {
            return CodeBlockItemListSyntax {
                if aggregate.function != .avg {
                    self.buildCalculateUpdateSyntax(for: aggregate)
                } else {
                    self.buildCalculateUpdateSyntax(for: aggregate, overwrite: .sum)
                    self.buildCalculateUpdateSyntax(for: aggregate, overwrite: .count)
                }
            }
        }
        
        private func buildCalculateUpdateSyntax(for aggregate: Aggregate, overwrite: AggregateFunction? = nil) -> InfixOperatorExprSyntax {
            return InfixOperatorExprSyntax(
                leftOperand: MemberAccessExprSyntax(
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
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier(aggregate.name)
                    )
                ),
                operator: self.buildCalculateOperationSyntax(aggregate: aggregate.function),
                rightOperand: self.buildCalculateRightOperandSyntax(aggregate: aggregate, overwrite: overwrite)
            )
        }
        
        private func buildCalculateRightOperandSyntax(aggregate: Aggregate, overwrite: AggregateFunction? = nil) -> any ExprSyntaxProtocol {
            let function = overwrite ?? aggregate.function
            
            switch function {
            case .count:
                return IntegerLiteralExprSyntax(literal: .integerLiteral("1"))
                
            case .sum, .avg:
                return FunctionCallExprSyntax(
                    calledExpression: DeclReferenceExprSyntax(
                        baseName: .identifier("Double")
                    ),
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax {
                        LabeledExprSyntax(
                            expression: MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(
                                    baseName: .identifier("row")
                                ),
                                declName: DeclReferenceExprSyntax(
                                    baseName: .identifier(SalesColumn(rawValue: aggregate.attribute)!.tupleNum)
                                )
                            )
                        )
                    },
                    rightParen: .rightParenToken()
                )
                
            case .max, .min:
                return FunctionCallExprSyntax(
                    calledExpression: DeclReferenceExprSyntax(
                        baseName: .identifier(aggregate.function == .max ? "max" : "min")
                    ),
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax {
                        LabeledExprSyntax(
                            expression: MemberAccessExprSyntax(
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
                                declName: DeclReferenceExprSyntax(
                                    baseName: .identifier(aggregate.name)
                                )
                            ),
                            trailingComma: .commaToken()
                        )
                        
                        LabeledExprSyntax(
                            expression: FunctionCallExprSyntax(
                                calledExpression: DeclReferenceExprSyntax(
                                    baseName: .identifier("Double")
                                ),
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax {
                                    LabeledExprSyntax(
                                        expression: MemberAccessExprSyntax(
                                            base: DeclReferenceExprSyntax(
                                                baseName: .identifier("row")
                                            ),
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier(SalesColumn(rawValue: aggregate.attribute)!.tupleNum)
                                            )
                                        )
                                    )
                                },
                                rightParen: .rightParenToken()
                            )
                        )
                    },
                    rightParen: .rightParenToken()
                )
            }
        }
        
        private func buildHavingFilterSyntax(_ havingPredicate: PredicateValue) -> InfixOperatorExprSyntax {
            return InfixOperatorExprSyntax(
                leftOperand: DeclReferenceExprSyntax(
                    baseName: .identifier("output")
                ),
                operator: AssignmentExprSyntax(),
                rightOperand: FunctionCallExprSyntax(
                    calledExpression: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(
                            baseName: .identifier("output")
                        ),
                        declName: DeclReferenceExprSyntax(
                            baseName: .identifier("filter")
                        )
                    ),
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax {
                        LabeledExprSyntax(
                            expression: ClosureExprSyntax(
                                statements: CodeBlockItemListSyntax {
                                    havingPredicate.syntax
                                }
                            )
                        )
                    },
                    rightParen: .rightParenToken(),
                    trailingTrivia: .newlines(2)
                )
            )
        }
        
        private func buildReturnSyntax() -> ReturnStmtSyntax {
            return ReturnStmtSyntax(
                expression: DeclReferenceExprSyntax(
                    baseName: .identifier("output")
                )
            )
        }
    }
}
