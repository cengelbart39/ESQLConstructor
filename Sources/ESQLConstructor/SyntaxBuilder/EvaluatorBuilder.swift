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
                            self.buildPopulateFuncSyntax(with: phi)
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
                        
                        self.populateFuncQuerySyntax()
                        
                        self.populateFuncForLoopSyntax(with: phi)
                        
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
                )
            )
        )
    }
        
    private func populateFuncQuerySyntax() -> CodeBlockItemSyntax {
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
    
    private func populateFuncForLoopSyntax(with phi: Phi) -> CodeBlockItemSyntax {
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
                        statements: CodeBlockItemListSyntax {
                            CodeBlockItemSyntax(
                                item: CodeBlockItemSyntax.Item(
                                    ExpressionStmtSyntax(
                                        expression: self.populateFuncIfExistsSyntax(with: phi)
                                    )
                                )
                            )
                        }
                    )
                )
            )
        )
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
}
