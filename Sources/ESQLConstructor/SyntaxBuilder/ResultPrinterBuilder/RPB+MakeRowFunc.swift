//
//  RPB+MakeRowFunc.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/15/24.
//  CWID: 10467610
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension ResultPrinterBuilder {
    struct MakeRowFuncBuilder {
        /// Builds the syntax for the `makeRow(in:as:)` function
        /// - Parameter phi: The current set of Phi parameters
        /// - Returns: A `FunctionDeclSyntax` wrapped in a `MemberBlockItemSyntax`
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
        /// private func makeRow(in table: inout Table, as mfStruct: MFStruct) {
        ///     let text0 = Text("\(mfStruct.cust)").justify(.left)
        ///     let text1 = Text("\(mfStruct.avg_1_quant)").justify(.right)
        ///     let text2 = Text("\(mfStruct.sum_2_quant.format())").justify(.right)
        ///     let text3 = Text("\(mfStruct.max_3_quant.format())").justify(.right)
        ///
        ///     table.addRow(text0, text1, text2, text3)
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
                    // makeRow
                    name: .identifier("makeRow"),
                    // (in table: inout Table, as mfStruct: MFStruct)
                    signature: self.buildFuncSignatureSyntax(),
                    // { ... }
                    body: self.buildFuncBodySyntax(with: phi)
                )
            )
        }
        
        /// Builds the function signature of the `makeRow(in:as:)` function
        /// - Returns: Syntax as a `FunctionSignatureSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// (in table: inout Table, as mfStruct: MFStruct)
        /// ```
        private func buildFuncSignatureSyntax() -> FunctionSignatureSyntax {
            return FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    // (
                    leftParen: .leftParenToken(),
                    parameters: FunctionParameterListSyntax {
                        // in table: inout Table
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
                        
                        // as mfStruct: MFStruct
                        FunctionParameterSyntax(
                            firstName: .identifier("as"),
                            secondName: .identifier("mfStruct"),
                            type: IdentifierTypeSyntax(
                                name: .identifier("MFStruct")
                            )
                        )
                    },
                    // )
                    rightParen: .rightParenToken()
                )
            )
        }
        
        /// <#Description#>
        /// - Parameter phi: <#phi description#>
        /// - Returns: <#description#>
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
        /// let text0 = Text("\(mfStruct.cust)").justify(.left)
        /// let text1 = Text("\(mfStruct.avg_1_quant)").justify(.right)
        /// let text2 = Text("\(mfStruct.sum_2_quant.format())").justify(.right)
        /// let text3 = Text("\(mfStruct.max_3_quant.format())").justify(.right)
        ///
        /// table.addRow(text0, text1, text2, text3)
        /// ```
        private func buildFuncBodySyntax(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    // Text(...).justify(...)
                    for index in 0..<phi.projectedValues.count {
                        let value = phi.projectedValues[index]
                        self.buildTextDeclSyntax(value, index: index, trailingTrivia: index == phi.projectedValues.count - 1 ? .newlines(2) : nil)
                    }
                    
                    // table.addRow(text0, text1, text2, text3)
                    self.buildAddRowExprSyntax(projValues: phi.projectedValues)
                }
            )
        }
        
        /// Builds the syntax for text declarations for table rows
        /// - Parameters:
        ///   - projValue: The projected value to build for
        ///   - index: The index of `projValue`
        ///   - trailingTrivia: Any trailing trivia
        /// - Returns: Syntax as a `VariableDeclSyntax`
        ///
        /// For the `String` and `Date` values, this function returns in the format:
        /// ```swift
        /// let text0 = Text("\(mfStruct.cust)").justify(.left)
        /// ```
        ///
        /// For `Double` values, this function returns in the format:
        /// ```swift
        /// let text2 = Text("\(mfStruct.sum_2_quant.format())").justify(.right)
        /// ```
        ///
        /// For `Average` values, this function returns in the format:
        /// ```swift
        /// let text1 = Text("\(mfStruct.avg_1_quant)").justify(.right)
        /// ```
        private func buildTextDeclSyntax(
            _ projValue: ProjectedValue,
            index: Int,
            trailingTrivia: Trivia? = nil
        ) -> VariableDeclSyntax {
            return VariableDeclSyntax(
                // let
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // text\(index)
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("text\(index)")
                        ),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                calledExpression: MemberAccessExprSyntax(
                                    base: FunctionCallExprSyntax(
                                        // Text
                                        calledExpression: DeclReferenceExprSyntax(
                                            baseName: .identifier("Text")
                                        ),
                                        // (
                                        leftParen: .leftParenToken(),
                                        arguments: LabeledExprListSyntax {
                                            LabeledExprSyntax(
                                                expression: StringLiteralExprSyntax(
                                                    // "
                                                    openingQuote: .stringQuoteToken(),
                                                    segments: StringLiteralSegmentListSyntax {
                                                        ExpressionSegmentSyntax(
                                                            // /
                                                            backslash: .backslashToken(),
                                                            // (
                                                            leftParen: .leftParenToken(),
                                                            // ...
                                                            expressions: LabeledExprListSyntax {
                                                                LabeledExprSyntax(
                                                                    expression: self.buildRowDataSyntax(projValue: projValue)
                                                                )
                                                            },
                                                            // )
                                                            rightParen: .rightParenToken()
                                                        )
                                                    },
                                                    // "
                                                    closingQuote: .stringQuoteToken()
                                                )
                                            )
                                        },
                                        // )
                                        rightParen: .rightParenToken()
                                    ),
                                    // justify
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier("justify")
                                    )
                                ),
                                // (
                                leftParen: .leftParenToken(),
                                // .left OR .right
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
                                // )
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                },
                trailingTrivia: trailingTrivia
            )
        }
        
        /// Builds the parameter of `Text` elements within a `Table` row
        /// - Parameter projValue: The value to build syntax for
        /// - Returns: If for a `Double` type, `FunctionCallExprSyntax`, otherwise, `MemberAccessExprSyntax`
        ///
        /// If value is a `Double`, builds the syntax in the following format:
        /// ```swift
        /// mfStruct.sum_2_quant.format()
        /// ```
        ///
        /// Otherwise, builds the syntax in the following format:
        /// ```swift
        /// mfStruct.cust
        /// ```
        private func buildRowDataSyntax(projValue: ProjectedValue) -> any ExprSyntaxProtocol {
            if projValue.type == .double {
                return FunctionCallExprSyntax(
                    calledExpression: MemberAccessExprSyntax(
                        base: MemberAccessExprSyntax(
                            // mfStruct
                            base: DeclReferenceExprSyntax(
                                baseName: .identifier("mfStruct")
                            ),
                            // <property>
                            declName: DeclReferenceExprSyntax(
                                baseName: .identifier(projValue.name)
                            )
                        ),
                        // format
                        declName: DeclReferenceExprSyntax(
                            baseName: .identifier("format")
                        )
                    ),
                    // (
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax { },
                    // )
                    rightParen: .rightParenToken()
                )
                
            } else {
                return MemberAccessExprSyntax(
                    // mfStruct
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier("mfStruct")
                    ),
                    // <property>
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier(projValue.name)
                    )
                )
            }
        }
        
        /// Builds the syntax for the function call that adds a row to the table
        /// - Parameter projValues: The values to add rows for
        /// - Returns: Builds syntax as a `FunctionCallExprSyntax`
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
        /// table.addRow(text0, text1, text2, text3)
        /// ```
        private func buildAddRowExprSyntax(projValues: [ProjectedValue]) -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
                // table.addRow
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier("table")
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("addRow")
                    )
                ),
                // (
                leftParen: .leftParenToken(),
                // all rows
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
                // )
                rightParen: .rightParenToken()
            )
        }
    }
}
