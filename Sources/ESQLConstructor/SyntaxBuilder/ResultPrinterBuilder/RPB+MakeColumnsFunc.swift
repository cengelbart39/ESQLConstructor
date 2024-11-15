//
//  RPB+MakeColumnsFunc.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/15/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension ResultPrinterBuilder {
    struct MakeColumnsFuncBuilder {
        func buildSyntax(with phi: Phi) -> MemberBlockItemSyntax {
            return MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    modifiers: DeclModifierListSyntax {
                        DeclModifierSyntax(
                            name: .keyword(.private)
                        )
                    },
                    funcKeyword: .keyword(.func),
                    name: .identifier("makeColumns"),
                    signature: self.buildFuncSignatureSyntax(),
                    body: self.buildFuncBodySyntax(with: phi),
                    trailingTrivia: .newlines(2)
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
                            )
                        )
                    },
                    rightParen: .rightParenToken()
                )
            )
        }
        
        private func buildFuncBodySyntax(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                leftBrace: .leftBraceToken(),
                statements: CodeBlockItemListSyntax {
                    FunctionCallExprSyntax(
                        calledExpression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(
                                baseName: .identifier("table")
                            ),
                            declName: DeclReferenceExprSyntax(
                                baseName: .identifier("addColumns")
                            )
                        ),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax {
                            for index in 0..<phi.projectedValues.count {
                                LabeledExprSyntax(
                                    expression: StringLiteralExprSyntax(
                                        openingQuote: .stringQuoteToken(),
                                        segments: StringLiteralSegmentListSyntax {
                                            StringSegmentSyntax(
                                                content: .stringSegment(phi.projectedValues[index].name)
                                            )
                                        },
                                        closingQuote: .stringQuoteToken()
                                    ),
                                    trailingComma: index == phi.projectedValues.count - 1 ? nil : .commaToken()
                                )
                            }
                        },
                        rightParen: .rightParenToken()
                    )
                },
                rightBrace: .rightBraceToken()
            )
        }
    }
}
