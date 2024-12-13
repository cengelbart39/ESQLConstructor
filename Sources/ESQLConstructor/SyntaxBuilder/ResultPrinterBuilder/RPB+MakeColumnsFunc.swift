//
//  RPB+MakeColumnsFunc.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/15/24.
//  CWID: 10467610
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension ResultPrinterBuilder {
    struct MakeColumnsFuncBuilder {
        /// Builds the syntax for the `makeColumns(in:)` function
        /// - Parameter phi: The current set of Phi parameters
        /// - Returns: A `FunctionDeclSyntax` wrapped in a  `MemberBlockItemSyntax`
        ///
        /// For the following query:
        /// ```sql
        /// SELECT cust, avg(NY.quant), sum(NJ.quant), max(CT.quant)
        /// FROM sales
        /// GROUP BY cust; NY, NJ, CT
        /// SUCH THAT NY.state = "NY"
        ///           NJ.state = "NJ"
        ///           CT.state = "CT"
        /// ```
        ///
        /// This function builds the following syntax:
        /// ```swift
        /// private func makeColumns(in table: inout Table) {
        ///     table.addColumns("cust", "avg_1_quant", "sum_2_quant", "max_3_quant")
        /// }
        /// ```
        func buildSyntax(with phi: Phi) -> MemberBlockItemSyntax {
            return MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    // private
                    modifiers: DeclModifierListSyntax {
                        DeclModifierSyntax(
                            name: .keyword(.private)
                        )
                    },
                    // func
                    funcKeyword: .keyword(.func),
                    // makeColumns
                    name: .identifier("makeColumns"),
                    // (in table: inout Table)
                    signature: self.buildFuncSignatureSyntax(),
                    // { ... }
                    body: self.buildFuncBodySyntax(with: phi),
                    trailingTrivia: .newlines(2)
                )
            )
        }
        
        /// Builds the syntax for the signature of the `makeColumns(in:)` function
        /// - Returns: Syntax as a `FunctionSignatureSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// (in table: inout Table)
        /// ```
        private func buildFuncSignatureSyntax() -> FunctionSignatureSyntax {
            return FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    // (
                    leftParen: .leftParenToken(),
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            // in
                            firstName: .identifier("in"),
                            // table
                            secondName: .identifier("table"),
                            // :
                            colon: .colonToken(),
                            type: AttributedTypeSyntax(
                                // inout
                                specifiers: TypeSpecifierListSyntax {
                                    SimpleTypeSpecifierSyntax(
                                        specifier: .keyword(.inout)
                                    )
                                },
                                // Table
                                baseType: IdentifierTypeSyntax(
                                    name: .identifier("Table")
                                )
                            )
                        )
                    },
                    // )
                    rightParen: .rightParenToken()
                )
            )
        }
        
        /// Builds the syntax for the body of the `makeColumns(in:)` function
        /// - Parameter phi: The current set of Phi parameters
        /// - Returns: A `FunctionCallExprSyntax` wrapped in a `CodeBlockSyntax`
        ///
        /// For the following query:
        /// ```sql
        /// SELECT cust, avg(NY.quant), sum(NJ.quant), max(CT.quant)
        /// FROM sales
        /// GROUP BY cust; NY, NJ, CT
        /// SUCH THAT NY.state = "NY"
        ///           NJ.state = "NJ"
        ///           CT.state = "CT"
        /// ```
        ///
        /// Builds the following syntax:
        /// ```swift
        /// table.addColumns("cust", "avg_1_quant", "sum_2_quant", "max_3_quant")
        /// ```
        private func buildFuncBodySyntax(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                // {
                leftBrace: .leftBraceToken(),
                statements: CodeBlockItemListSyntax {
                    FunctionCallExprSyntax(
                        // table.addColumns
                        calledExpression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(
                                baseName: .identifier("table")
                            ),
                            declName: DeclReferenceExprSyntax(
                                baseName: .identifier("addColumns")
                            )
                        ),
                        // (
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax {
                            // Projected Values
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
                        // )
                        rightParen: .rightParenToken()
                    )
                },
                // }
                rightBrace: .rightBraceToken()
            )
        }
    }
}
