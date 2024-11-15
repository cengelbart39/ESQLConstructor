//
//  RPB+MakeRowFunc.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/15/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension ResultPrinterBuilder {
    struct MakeRowFuncBuilder {
        func buildSyntax(with phi: Phi) -> MemberBlockItemSyntax {
            return MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    modifiers: DeclModifierListSyntax {
                        DeclModifierSyntax(
                            name: .keyword(.private)
                        )
                    },
                    funcKeyword: .keyword(.func),
                    name: .identifier("makeRow"),
                    signature: self.buildFuncSignatureSyntax(),
                    body: self.buildFuncBodySyntax(with: phi)
                )
            )
        }
        
        private func buildFuncSignatureSyntax() -> FunctionSignatureSyntax {
            return FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    leftParen: .leftParenToken(),
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            firstName: .identifier("in"),
                            secondName: .identifier("table"),
                            type: AttributedTypeSyntax(
                                specifiers: TypeSpecifierListSyntax {
                                    SimpleTypeSpecifierSyntax(
                                        specifier: .keyword(.inout)
                                    )
                                },
                                baseType: IdentifierTypeSyntax(
                                    name: .identifier("Table")
                                )
                            ),
                            trailingComma: .commaToken()
                        )
                        
                        FunctionParameterSyntax(
                            firstName: .identifier("as"),
                            secondName: .identifier("mfStruct"),
                            type: IdentifierTypeSyntax(
                                name: .identifier("MFStruct")
                            )
                        )
                    },
                    rightParen: .rightParenToken()
                )
            )
        }
        
        private func buildFuncBodySyntax(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    for index in 0..<phi.projectedValues.count {
                        let value = phi.projectedValues[index]
                        self.buildTextDeclSyntax(value, index: index, trailingTrivia: index == phi.projectedValues.count - 1 ? .newlines(2) : nil)
                    }
                    
                    self.buildAddRowExprSyntax(projValues: phi.projectedValues)
                }
            )
        }
        
        private func buildTextDeclSyntax(
            _ projValue: ProjectedValue,
            index: Int,
            trailingTrivia: Trivia? = nil
        ) -> VariableDeclSyntax {
            return VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("text\(index)")
                        ),
                        initializer: InitializerClauseSyntax(
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                calledExpression: MemberAccessExprSyntax(
                                    base: FunctionCallExprSyntax(
                                        calledExpression: DeclReferenceExprSyntax(
                                            baseName: .identifier("Text")
                                        ),
                                        leftParen: .leftParenToken(),
                                        arguments: LabeledExprListSyntax {
                                            LabeledExprSyntax(
                                                expression: StringLiteralExprSyntax(
                                                    openingQuote: .stringQuoteToken(),
                                                    segments: StringLiteralSegmentListSyntax {
                                                        ExpressionSegmentSyntax(
                                                            expressions: LabeledExprListSyntax {
                                                                LabeledExprSyntax(
                                                                    expression: self.buildRowDataSyntax(projValue: projValue)
                                                                )
                                                            }
                                                        )
                                                    },
                                                    closingQuote: .stringQuoteToken()
                                                )
                                            )
                                        },
                                        rightParen: .rightParenToken()
                                    ),
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier("justify")
                                    )
                                ),
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax {
                                    let justification = projValue.type == .double || projValue.type == .average ? "right" : "left"
                                    LabeledExprSyntax(
                                        expression: MemberAccessExprSyntax(
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier(justification)
                                            )
                                        )
                                    )
                                },
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                },
                trailingTrivia: trailingTrivia
            )
        }
        
        private func buildRowDataSyntax(projValue: ProjectedValue) -> any ExprSyntaxProtocol {
            if projValue.type == .double {
                return FunctionCallExprSyntax(
                    calledExpression: MemberAccessExprSyntax(
                        base: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(
                                baseName: .identifier("mfStruct")
                            ),
                            declName: DeclReferenceExprSyntax(
                                baseName: .identifier(projValue.name)
                            )
                        ),
                        declName: DeclReferenceExprSyntax(
                            baseName: .identifier("format")
                        )
                    ),
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax { },
                    rightParen: .rightParenToken()
                )
                
            } else {
                return MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier("mfStruct")
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier(projValue.name)
                    )
                )
            }
        }
        
        private func buildAddRowExprSyntax(projValues: [ProjectedValue]) -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier("table")
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("addRow")
                    )
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    for index in 0..<projValues.count {
                        LabeledExprSyntax(
                            expression: DeclReferenceExprSyntax(
                                baseName: .identifier("text\(index)")
                            ),
                            trailingComma: index == projValues.count - 1 ? nil : .commaToken()
                        )
                    }
                },
                rightParen: .rightParenToken()
            )
        }
    }
}
