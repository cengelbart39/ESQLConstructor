//
//  EvaluatorBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/27/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

struct EvaluatorBuilder {
    private func buildImportSyntax() -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                ImportDeclSyntax(
                    path: ImportPathComponentListSyntax {
                        ImportPathComponentSyntax(
                            name: .identifier("Foundation")
                        )
                    },
                    trailingTrivia: .newlines(2)
                )
            )
        )
    }
    
    private func buildTypealiasSyntax() -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                TypeAliasDeclSyntax(
                    name: .identifier("Sales"),
                    initializer: TypeInitializerClauseSyntax(
                        value: TupleTypeSyntax(
                            elements: TupleTypeElementListSyntax {
                                TupleTypeElementSyntax(
                                    type: IdentifierTypeSyntax(
                                        name: .identifier("String")
                                    ),
                                    trailingComma: .commaToken()
                                )
                                
                                TupleTypeElementSyntax(
                                    type: IdentifierTypeSyntax(
                                        name: .identifier("String")
                                    ),
                                    trailingComma: .commaToken()
                                )
                                
                                TupleTypeElementSyntax(
                                    type: IdentifierTypeSyntax(
                                        name: .identifier("Int")
                                    ),
                                    trailingComma: .commaToken()
                                )
                                
                                TupleTypeElementSyntax(
                                    type: IdentifierTypeSyntax(
                                        name: .identifier("Int")
                                    ),
                                    trailingComma: .commaToken()
                                )
                                
                                TupleTypeElementSyntax(
                                    type: IdentifierTypeSyntax(
                                        name: .identifier("Int")
                                    ),
                                    trailingComma: .commaToken()
                                )
                                
                                TupleTypeElementSyntax(
                                    type: IdentifierTypeSyntax(
                                        name: .identifier("String")
                                    ),
                                    trailingComma: .commaToken()
                                )
                                
                                TupleTypeElementSyntax(
                                    type: IdentifierTypeSyntax(
                                        name: .identifier("Int")
                                    ),
                                    trailingComma: .commaToken()
                                )
                                
                                TupleTypeElementSyntax(
                                    type: IdentifierTypeSyntax(
                                        name: .identifier("Date")
                                    )
                                )
                            }
                        )
                    ),
                    trailingTrivia: .newlines(2)
                )
            )
        )
    }
    
    private func buildStructSyntax(with phi: Phi) -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                StructDeclSyntax(
                    name: .identifier("Evaluator"),
                    memberBlock: MemberBlockSyntax(
                        members: MemberBlockItemListSyntax {
                            self.buildPropertySyntax()
                            self.buildInitSyntax()
                            self.buildEvaluateFuncSyntax(with: phi)
                            self.buildPopulateFuncSyntax(with: phi)
                            self.buildCalculateAggregateFuncSyntax(with: phi)
                        }
                    )
                )
            )
        )
    }
    
    private func buildPropertySyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("service")
                        ),
                        typeAnnotation: TypeAnnotationSyntax(
                            type: IdentifierTypeSyntax(
                                name: .identifier("PostgresService")
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    private func buildInitSyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: InitializerDeclSyntax(
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        parameters: FunctionParameterListSyntax {
                            FunctionParameterSyntax(
                                firstName: .identifier("service"),
                                type: IdentifierTypeSyntax(
                                    name: .identifier("PostgresService")
                                )
                            )
                        }
                    )
                ),
                body: CodeBlockSyntax(
                    statements: CodeBlockItemListSyntax {
                        CodeBlockItemSyntax(
                            item: CodeBlockItemSyntax.Item(
                                InfixOperatorExprSyntax(
                                    leftOperand: MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax(
                                            baseName: .keyword(.self)
                                        ),
                                        declName: DeclReferenceExprSyntax(
                                            baseName: .identifier("service")
                                        )
                                    ),
                                    operator: AssignmentExprSyntax(),
                                    rightOperand: DeclReferenceExprSyntax(
                                        baseName: .identifier("service")
                                    )
                                )
                            )
                        )
                    }
                ),
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    private func buildEvaluateFuncSyntax(with phi: Phi) -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: FunctionDeclSyntax(
                name: .identifier("evaluate"),
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        leftParen: .leftParenToken(),
                        parameters: FunctionParameterListSyntax { },
                        rightParen: .rightParenToken()
                    ),
                    effectSpecifiers: FunctionEffectSpecifiersSyntax(
                        asyncSpecifier: .keyword(.async),
                        throwsClause: ThrowsClauseSyntax(
                            throwsSpecifier: .keyword(.throws)
                        )
                    )
                ),
                body: CodeBlockSyntax(
                    statements: CodeBlockItemListSyntax {
                        CodeBlockItemSyntax(
                            item: CodeBlockItemSyntax.Item(
                                TryExprSyntax(
                                    expression: AwaitExprSyntax(
                                        expression: FunctionCallExprSyntax(
                                            calledExpression: DeclReferenceExprSyntax(
                                                baseName: .identifier("withThrowingTaskGroup")
                                            ),
                                            leftParen: .leftParenToken(),
                                            arguments: LabeledExprListSyntax {
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
                                            rightParen: .rightParenToken(),
                                            trailingClosure: ClosureExprSyntax(
                                                signature: ClosureSignatureSyntax(
                                                    parameterClause: .simpleInput(
                                                        ClosureShorthandParameterListSyntax {
                                                            ClosureShorthandParameterSyntax(
                                                                name: .identifier("taskGroup")
                                                            )
                                                        }
                                                    )
                                                ),
                                                statements: CodeBlockItemListSyntax {
                                                    self.evaluateRunTaskSyntax()
                                                    self.evaluatePopulateSyntax()
                                                    self.evaluateTaskCancelSyntax()
                                                }
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    }
                ),
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    private func evaluateRunTaskSyntax() -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: .expr(
                ExprSyntax(
                    FunctionCallExprSyntax(
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
                            statements: CodeBlockItemListSyntax {
                                CodeBlockItemSyntax(
                                    item: .expr(
                                        ExprSyntax(
                                            AwaitExprSyntax(
                                                expression: FunctionCallExprSyntax(
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
                                                    leftParen: .leftParenToken(),
                                                    arguments: LabeledExprListSyntax { },
                                                    rightParen: .rightParenToken()
                                                )
                                            )
                                        )
                                    )
                                )
                            }
                        ),
                        trailingTrivia: .newlines(2)
                    )
                )
            )
        )
    }
    
    private func evaluatePopulateSyntax() -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: .decl(
                DeclSyntax(
                    VariableDeclSyntax(
                        bindingSpecifier: .keyword(.var),
                        bindings: PatternBindingListSyntax {
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(
                                    identifier: .identifier("mfStructs")
                                ),
                                initializer: InitializerClauseSyntax(
                                    value: TryExprSyntax(
                                        expression: AwaitExprSyntax(
                                            expression: FunctionCallExprSyntax(
                                                calledExpression: MemberAccessExprSyntax(
                                                    base: DeclReferenceExprSyntax(
                                                        baseName: .keyword(.self)
                                                    ),
                                                    declName: DeclReferenceExprSyntax(
                                                        baseName: .identifier("populateMFStruct")
                                                    )
                                                ),
                                                leftParen: .leftParenToken(),
                                                arguments: LabeledExprListSyntax { },
                                                rightParen: .rightParenToken()
                                            )
                                        )
                                    )
                                )
                            )
                        },
                        trailingTrivia: .newlines(2)
                    )
                )
            )
        )
    }
    
    private func evaluateTaskCancelSyntax() -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: .expr(
                ExprSyntax(
                    FunctionCallExprSyntax(
                        calledExpression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(
                                baseName: .identifier("taskGroup")
                            ),
                            declName: DeclReferenceExprSyntax(
                                baseName: .identifier("cancelAll")
                            )
                        ),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax { },
                        rightParen: .rightParenToken()
                    )
                )
            )
        )
    }
    
    private func buildPopulateFuncSyntax(with phi: Phi) -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: FunctionDeclSyntax(
                name: .identifier("populateMFStruct"),
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        parameters: FunctionParameterListSyntax { }
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
                ),
                body: CodeBlockSyntax(
                    statements: CodeBlockItemListSyntax {
                        CodeBlockItemSyntax(
                            item: CodeBlockItemSyntax.Item(
                                VariableDeclSyntax(
                                    bindingSpecifier: .keyword(.var),
                                    bindings: PatternBindingListSyntax {
                                        PatternBindingSyntax(
                                            pattern: IdentifierPatternSyntax(
                                                identifier: .identifier("mfStructs")
                                            ),
                                            initializer: InitializerClauseSyntax(
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
                            )
                        )
                        
                        self.queryRowsSyntax()
                        
                        self.decodeRowsSyntax(with: phi, for: .populate)
                        
                        CodeBlockItemSyntax(
                            item: CodeBlockItemSyntax.Item(
                                ReturnStmtSyntax(
                                    expression: DeclReferenceExprSyntax(
                                        baseName: .identifier("mfStructs")
                                    )
                                )
                            )
                        )
                    }
                ),
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    private func queryRowsSyntax() -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                VariableDeclSyntax(
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
            )
        )
    }
    
    private func decodeRowsSyntax(with phi: Phi, for decodeType: DecodeRowType) -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                ForStmtSyntax(
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
                    body: CodeBlockSyntax(
                        statements: self.rowDecodeOperationSyntax(with: phi, for: decodeType)
                    ),
                    trailingTrivia: .newlines(2)
                )
            )
        )
    }
    
    private func rowDecodeOperationSyntax(with phi: Phi, for decodeType: DecodeRowType) -> CodeBlockItemListSyntax {
        switch decodeType {
        case .populate:
            return CodeBlockItemListSyntax {
                CodeBlockItemSyntax(
                    item: CodeBlockItemSyntax.Item(
                        ExpressionStmtSyntax(
                            expression: self.populateFuncIfExistsSyntax(with: phi)
                        )
                    )
                )
            }
        case .aggregate:
            return self.aggreateFuncCalculateSyntax(with: phi)
        }
    }
    
    private func populateFuncIfExistsSyntax(with phi: Phi) -> IfExprSyntax {
        return IfExprSyntax(
            conditions: ConditionElementListSyntax {
                self.populateFuncIfConditionSyntax(with: phi)
            },
            body: self.populateFuncIfBodySyntax(with: phi)
        )
    }
    
    private func populateFuncIfConditionSyntax(with phi: Phi) -> ConditionElementSyntax {
        return ConditionElementSyntax(
            condition: .expression(
                ExprSyntax(
                    PrefixOperatorExprSyntax(
                        operator: .prefixOperator("!"),
                        expression: FunctionCallExprSyntax(
                            calledExpression: MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(
                                    baseName: .identifier("mfStructs")
                                ),
                                declName: DeclReferenceExprSyntax(
                                    baseName: .identifier("exists")
                                )
                            ),
                            leftParen: .leftParenToken(),
                            arguments: LabeledExprListSyntax {
                                let attributes = phi.projectedValues.attributes()
                                
                                for index in 0..<attributes.count {
                                    let attribute = attributes[index]
                                    
                                    LabeledExprSyntax(
                                        label: .identifier(attribute.name),
                                        colon: .colonToken(),
                                        expression: MemberAccessExprSyntax(
                                            base: DeclReferenceExprSyntax(
                                                baseName: .identifier("row")
                                            ),
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier(SalesColumn(rawValue: attribute.name)!.tupleNum)
                                            )
                                        )
                                    )
                                }
                            },
                            rightParen: .rightParenToken()
                        )
                    )
                )
            )
        )
    }
    
    private func populateFuncIfBodySyntax(with phi: Phi) -> CodeBlockSyntax {
        return CodeBlockSyntax(
            statements: CodeBlockItemListSyntax {
                CodeBlockItemSyntax(
                    item: CodeBlockItemSyntax.Item(
                        VariableDeclSyntax(
                            bindingSpecifier: .keyword(.let),
                            bindings: PatternBindingListSyntax {
                                PatternBindingSyntax(
                                    pattern: IdentifierPatternSyntax(
                                        identifier: .identifier("mfStruct")
                                    ),
                                    initializer: InitializerClauseSyntax(
                                        value: FunctionCallExprSyntax(
                                            calledExpression: DeclReferenceExprSyntax(
                                                baseName: .identifier("MFStruct")
                                            ),
                                            leftParen: .leftParenToken(),
                                            arguments: LabeledExprListSyntax {
                                                let attributes = phi.projectedValues.attributes()
                                                let aggregates = phi.aggregates
                                                
                                                for index in 0..<attributes.count {
                                                    let attribute = attributes[index]
                                                    
                                                    LabeledExprSyntax(
                                                        label: .identifier(attribute.name),
                                                        colon: .colonToken(),
                                                        expression: MemberAccessExprSyntax(
                                                            base: DeclReferenceExprSyntax(
                                                                baseName: .identifier("row")
                                                            ),
                                                            declName: DeclReferenceExprSyntax(
                                                                baseName: .identifier(SalesColumn(rawValue: attribute.name)!.tupleNum)
                                                            )
                                                        ),
                                                        trailingComma: index == phi.projectedValues.count - 1 ? nil : .commaToken()
                                                    )
                                                }
                                                
                                                for index in 0..<aggregates.count {
                                                    let aggregate = aggregates[index]
                                                    
                                                    LabeledExprSyntax(
                                                        label: .identifier(aggregate.name),
                                                        colon: .colonToken(),
                                                        expression: aggregate.function.defaultSyntax,
                                                        trailingComma: index == aggregates.count - 1 ? nil : .commaToken()
                                                    )
                                                }
                                            },
                                            rightParen: .rightParenToken()
                                        )
                                    )
                                )
                            },
                            trailingTrivia: .newlines(2)
                        )
                    )
                )
                
                CodeBlockItemSyntax(
                    item: CodeBlockItemSyntax.Item(
                        FunctionCallExprSyntax(
                            calledExpression: MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(
                                    baseName: .identifier("mfStructs")
                                ),
                                declName: DeclReferenceExprSyntax(
                                    baseName: .identifier("append")
                                )
                            ),
                            leftParen: .leftParenToken(),
                            arguments: LabeledExprListSyntax {
                                LabeledExprSyntax(
                                    expression: DeclReferenceExprSyntax(
                                        baseName: .identifier("mfStruct")
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
    
    private func buildCalculateAggregateFuncSyntax(with phi: Phi) -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: FunctionDeclSyntax(
                name: .identifier("computeAggregates"),
                signature: FunctionSignatureSyntax(
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
                ),
                body: CodeBlockSyntax(
                    statements: CodeBlockItemListSyntax {
                        CodeBlockItemSyntax(
                            item: CodeBlockItemSyntax.Item(
                                VariableDeclSyntax(
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
                            )
                        )
                        
                        self.queryRowsSyntax()
                        
                        self.decodeRowsSyntax(with: phi, for: .aggregate)
                        
                        CodeBlockItemSyntax(
                            item: CodeBlockItemSyntax.Item(
                                ReturnStmtSyntax(
                                    expression: DeclReferenceExprSyntax(
                                        baseName: .identifier("output")
                                    )
                                )
                            )
                        )
                    }
                )
            )
        )
    }
    
    private func aggreateFuncCalculateSyntax(with phi: Phi) -> CodeBlockItemListSyntax {
        return CodeBlockItemListSyntax {
            CodeBlockItemSyntax(
                item: CodeBlockItemSyntax.Item(
                    VariableDeclSyntax(
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
                                        arguments: LabeledExprListSyntax {
                                            let attributes = phi.projectedValues.attributes()
                                            for index in 0..<attributes.count {
                                                LabeledExprSyntax(
                                                    label: .identifier(attributes[index].name),
                                                    colon: .colonToken(),
                                                    expression: MemberAccessExprSyntax(
                                                        base: DeclReferenceExprSyntax(
                                                            baseName: .identifier("row")
                                                        ),
                                                        declName: DeclReferenceExprSyntax(
                                                            baseName: .identifier(SalesColumn(rawValue: attributes[index].name)!.tupleNum)
                                                        )
                                                    ),
                                                    trailingComma: index == attributes.count - 1 ? nil : .commaToken()
                                                )
                                            }
                                        },
                                        rightParen: .rightParenToken()
                                    )
                                )
                            )
                        }
                    )
                )
            )
            
            let aggregates = phi.aggregates
            for index in 0..<aggregates.count {
                CodeBlockItemSyntax(
                    item: .expr(
                        ExprSyntax(
                            IfExprSyntax(
                                conditions: ConditionElementListSyntax {
                                    ConditionElementSyntax(
                                        condition: .expression(
                                            ExprSyntax(
                                                TupleExprSyntax(
                                                    elements: LabeledExprListSyntax {
                                                        LabeledExprSyntax(
                                                            expression: self.aggregateCalculateConditionSyntax(
                                                                predicates: phi.groupingVarPredicates.find(
                                                                    for: aggregates[index].groupingVarId
                                                                ),
                                                                for: SalesColumn(rawValue: aggregates[index].attribute)!.tupleNum
                                                            )
                                                        )
                                                    }
                                                )
                                            )
                                        )
                                    )
                                },
                                body: CodeBlockSyntax(
                                    statements: CodeBlockItemListSyntax {
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
                                                    baseName: .identifier(aggregates[index].name)
                                                )
                                            ),
                                            operator: self.aggregateCalculateOperationSyntax(aggregate: aggregates[index]),
                                            rightOperand: self.aggreateCalculateRightOperandSyntax(aggregate: aggregates[index])
                                        )
                                    }
                                ),
                                trailingTrivia: index == aggregates.count - 1 ? nil : .newlines(2)
                            )
                        )
                    )
                )
            }
        }
    }
    
    private func aggregateCalculateConditionSyntax(predicates: [Predicate], for item: String) -> InfixOperatorExprSyntax {
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
                leftOperand: self.aggregateCalculateConditionSyntax(predicates: rest, for: item),
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
    
    private func aggregateCalculateOperationSyntax(aggregate: Aggregate) -> any ExprSyntaxProtocol {
        if aggregate.function == .max || aggregate.function == .min {
            return AssignmentExprSyntax()
            
        } else {
            return BinaryOperatorExprSyntax(
                operator: .binaryOperator("+=")
            )
        }
    }
    
    private func aggreateCalculateRightOperandSyntax(aggregate: Aggregate) -> any ExprSyntaxProtocol {
        switch aggregate.function {
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
    
    public func generateSyntax(with phi: Phi) -> String {
        let syntax = SourceFileSyntax(
            statements: CodeBlockItemListSyntax {
                self.buildImportSyntax()
                self.buildTypealiasSyntax()
                self.buildStructSyntax(with: phi)
            }
        )
        
        return syntax.formatted().description
    }
    
    enum DecodeRowType {
        case populate
        case aggregate
    }
}
