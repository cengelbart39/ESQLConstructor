//
//  RPB+PrintFunc.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/15/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension ResultPrinterBuilder {
    struct PrintFuncBuilder {
        func buildSyntax() -> MemberBlockItemSyntax {
            return MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    // func
                    funcKeyword: .keyword(.func),
                    // print
                    name: .identifier("print"),
                    // (_ mfStructs: [MFStruct])
                    signature: self.buildFuncSignatureSyntax(),
                    body: self.buildFuncBodySyntax(),
                    trailingTrivia: .newlines(2)
                )
            )
        }
        
        private func buildFuncSignatureSyntax() -> FunctionSignatureSyntax {
            return FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    // (
                    leftParen: .leftParenToken(),
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            // _
                            firstName: .wildcardToken(),
                            // mfStructs
                            secondName: .identifier("mfStructs"),
                            // :
                            colon: .colonToken(),
                            // [MFStruct]
                            type: ArrayTypeSyntax(
                                element: IdentifierTypeSyntax(
                                    name: .identifier("MFStruct")
                                )
                            )
                        )
                    },
                    // )
                    rightParen: .rightParenToken()
                )
            )
        }
        
        private func buildFuncBodySyntax() -> CodeBlockSyntax {
            return CodeBlockSyntax(
                // {
                leftBrace: .leftBraceToken(),
                statements: CodeBlockItemListSyntax {
                    // let console = Console()
                    self.buildConsoleDeclSyntax()
                    
                    // var table = Table()
                    self.buildTableDeclSyntax()
                    
                    // self.makeColumns(in: &table)
                    self.buildMakeColumnsExprSyntax()
                    
                    // for item in mfStructs { ... }
                    self.buildMakeRowsStmtSyntax()
                    
                    // console.write(table)
                    self.buildConsoleWriteExprSyntax()
                },
                // }
                rightBrace: .rightBraceToken()
            )
        }
        
        private func buildConsoleDeclSyntax() -> VariableDeclSyntax {
            return VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("console")
                        ),
                        initializer: InitializerClauseSyntax(
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                calledExpression: DeclReferenceExprSyntax(
                                    baseName: .identifier("Console")
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
        
        private func buildTableDeclSyntax() -> VariableDeclSyntax {
            return VariableDeclSyntax(
                bindingSpecifier: .keyword(.var),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("table")
                        ),
                        initializer: InitializerClauseSyntax(
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                calledExpression: DeclReferenceExprSyntax(
                                    baseName: .identifier("Table")
                                ),
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax { },
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                }
            )
        }
        
        private func buildMakeColumnsExprSyntax() -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .keyword(.self)
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("makeColumns")
                    )
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        label: .identifier("in"),
                        colon: .colonToken(),
                        expression: InOutExprSyntax(
                            expression: DeclReferenceExprSyntax(
                                baseName: .identifier("table")
                            )
                        )
                    )
                },
                rightParen: .rightParenToken()
            )
        }
        
        private func buildMakeRowsStmtSyntax() -> ForStmtSyntax {
            return ForStmtSyntax(
                forKeyword: .keyword(.for),
                pattern: IdentifierPatternSyntax(
                    identifier: .identifier("item")
                ),
                inKeyword: .keyword(.in),
                sequence: DeclReferenceExprSyntax(
                    baseName: .identifier("mfStructs")
                ),
                body: CodeBlockSyntax(
                    leftBrace: .leftBraceToken(),
                    statements: CodeBlockItemListSyntax {
                        FunctionCallExprSyntax(
                            calledExpression: MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(
                                    baseName: .keyword(.self)
                                ),
                                declName: DeclReferenceExprSyntax(
                                    baseName: .identifier("makeRow")
                                )
                            ),
                            leftParen: .leftParenToken(),
                            arguments: LabeledExprListSyntax {
                                LabeledExprSyntax(
                                    label: .identifier("in"),
                                    colon: .colonToken(),
                                    expression: InOutExprSyntax(
                                        expression: DeclReferenceExprSyntax(
                                            baseName: .identifier("table")
                                        )
                                    ),
                                    trailingComma: .commaToken()
                                )
                                
                                LabeledExprSyntax(
                                    label: .identifier("as"),
                                    colon: .colonToken(),
                                    expression: DeclReferenceExprSyntax(
                                        baseName: .identifier("item")
                                    )
                                )
                            },
                            rightParen: .rightParenToken()
                        )
                    },
                    rightBrace: .rightBraceToken()
                )
            )
        }
        
        private func buildConsoleWriteExprSyntax() -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier("console")
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("write")
                    )
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier("table")
                        )
                    )
                },
                rightParen: .rightParenToken()
            )
        }
    }
}
