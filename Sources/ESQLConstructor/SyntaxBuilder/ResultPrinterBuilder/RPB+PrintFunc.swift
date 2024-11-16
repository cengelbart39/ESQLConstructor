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
        /// Builds the `print(_:)` function of `ResultPrinter`
        /// - Returns: Syntax as a `FunctionDeclSyntax` wrapped in a `MemberBlockItemSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// func print(_ mfStructs: [MFStruct]) {
        ///     let console = Console()
        ///
        ///     var table = Table()
        ///     self.makeColumns(in: &table)
        ///
        ///     for item in mfStructs {
        ///         self.makeRow(in: &table, as: item)
        ///     }
        ///
        ///     console.write(table)
        /// }
        /// ```
        func buildSyntax() -> MemberBlockItemSyntax {
            return MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    // func
                    funcKeyword: .keyword(.func),
                    // print
                    name: .identifier("print"),
                    // (_ mfStructs: [MFStruct])
                    signature: self.buildFuncSignatureSyntax(),
                    // { ... }
                    body: CodeBlockSyntax(
                        leftBrace: .leftBraceToken(),
                        statements: self.buildFuncBodySyntax(),
                        rightBrace: .rightBraceToken()
                    ),
                    trailingTrivia: .newlines(2)
                )
            )
        }
        
        /// Builds the `FunctionSignatureSyntax` for the `print(_:)` function
        ///
        /// Builds the following syntax:
        /// ```swift
        /// (_ mfStructs: [MFStruct])
        /// ```
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
        
        /// Builds the body of the `print(:_)` function
        /// - Returns: The body as a `CodeBlockSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// let console = Console()
        ///
        /// var table = Table()
        /// self.makeColumns(in: &table)
        ///
        /// for item in mfStructs {
        ///     self.makeRow(in: &table, as: item)
        /// }
        ///
        /// console.write(table)
        /// ```
        private func buildFuncBodySyntax() -> CodeBlockItemListSyntax {
            return CodeBlockItemListSyntax {
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
                }
        }
        
        /// Builds a constant declaration for a `Console`
        /// - Returns: Syntax as a `VariableDeclSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// let console = Console()
        /// ```
        private func buildConsoleDeclSyntax() -> VariableDeclSyntax {
            return VariableDeclSyntax(
                // let
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // console
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("console")
                        ),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            // Console()
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
        
        /// Builds a variable declaration for a `Table`
        /// - Returns: Syntax as a `VariableDeclSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// var table = Table()
        /// ```
        private func buildTableDeclSyntax() -> VariableDeclSyntax {
            return VariableDeclSyntax(
                // var
                bindingSpecifier: .keyword(.var),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // table
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("table")
                        ),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            // Table()
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
        
        /// Builds syntax for the function call that sets the `Table` columns
        /// - Returns: Syntax as a `FunctionCallExprSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// self.makeColumns(in: &table)
        /// ```
        private func buildMakeColumnsExprSyntax() -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
                // self.makeColumns
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .keyword(.self)
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("makeColumns")
                    )
                ),
                // (
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        // in
                        label: .identifier("in"),
                        // :
                        colon: .colonToken(),
                        // &table
                        expression: InOutExprSyntax(
                            expression: DeclReferenceExprSyntax(
                                baseName: .identifier("table")
                            )
                        )
                    )
                },
                // )
                rightParen: .rightParenToken(),
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds syntax for the function call that sets the `Table` rows
        /// - Returns: Syntax as a `ForStmtSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// for item in mfStructs {
        ///     self.makeRow(in: &table, as: item)
        /// }
        /// ```
        private func buildMakeRowsStmtSyntax() -> ForStmtSyntax {
            return ForStmtSyntax(
                // for
                forKeyword: .keyword(.for),
                // item
                pattern: IdentifierPatternSyntax(
                    identifier: .identifier("item")
                ),
                // in
                inKeyword: .keyword(.in),
                // mfStructs
                sequence: DeclReferenceExprSyntax(
                    baseName: .identifier("mfStructs")
                ),
                body: CodeBlockSyntax(
                    // {
                    leftBrace: .leftBraceToken(),
                    statements: CodeBlockItemListSyntax {
                        FunctionCallExprSyntax(
                            // self.makeRow
                            calledExpression: MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(
                                    baseName: .keyword(.self)
                                ),
                                declName: DeclReferenceExprSyntax(
                                    baseName: .identifier("makeRow")
                                )
                            ),
                            // (
                            leftParen: .leftParenToken(),
                            arguments: LabeledExprListSyntax {
                                // in: table
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
                                
                                // as: item
                                LabeledExprSyntax(
                                    label: .identifier("as"),
                                    colon: .colonToken(),
                                    expression: DeclReferenceExprSyntax(
                                        baseName: .identifier("item")
                                    )
                                )
                            },
                            // )
                            rightParen: .rightParenToken()
                        )
                    },
                    // }
                    rightBrace: .rightBraceToken()
                ),
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the syntax for the function call that writes the `Table` to the console
        /// - Returns: Syntax as `FunctionCallExprSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// console.write(table)
        /// ```
        private func buildConsoleWriteExprSyntax() -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
                // console.write
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier("console")
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("write")
                    )
                ),
                // (
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    // table
                    LabeledExprSyntax(
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier("table")
                        )
                    )
                },
                // )
                rightParen: .rightParenToken()
            )
        }
    }
}
