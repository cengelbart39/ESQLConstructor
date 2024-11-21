//
//  EB+PopulateFunc.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public extension EvaluatorBuilder {
    struct PopulateFuncBuilder {
        /// Builds the syntax for `Evaluator`'s `populateMFStruct()` function
        /// - Parameter phi: Phi operator used in decoding
        /// - Returns: The syntax as a `MemberBlockItemSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// private func populate(_ mfStructs: inout [MFStruct], with row: Sales) {
        ///     let item = MFStruct(
        ///         cust: row.0,
        ///         avg_1_quant: Average(),
        ///         sum_2_quant: .zero,
        ///         max_3_quant: Double(Int.min)
        ///     )
        ///
        ///     mfStructs.append(item)
        /// }
        /// ```
        public func buildSyntax(with phi: Phi) -> MemberBlockItemSyntax {
            return MemberBlockItemSyntax(
                decl: FunctionDeclSyntax(
                    modifiers: DeclModifierListSyntax {
                        DeclModifierSyntax(
                            name: .keyword(.private)
                        )
                    },
                    funcKeyword: .keyword(.func),
                    name: .identifier("populate"),
                    signature: self.buildFuncSignatureSyntax(),
                    body: self.buildFuncBodySyntax(with: phi),
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
                        // _ mfStructs: inout [MFStruct]
                        FunctionParameterSyntax(
                            firstName: .wildcardToken(),
                            secondName: .identifier("mfStructs"),
                            colon: .colonToken(),
                            type: AttributedTypeSyntax(
                                specifiers: TypeSpecifierListSyntax {
                                    SimpleTypeSpecifierSyntax(
                                        specifier: .keyword(.inout)
                                    )
                                },
                                baseType: ArrayTypeSyntax(
                                    element: IdentifierTypeSyntax(
                                        name: .identifier("MFStruct")
                                    )
                                )
                            ),
                            trailingComma: .commaToken()
                        )
                        
                        // with row: Sales
                        FunctionParameterSyntax(
                            firstName: .identifier("with"),
                            secondName: .identifier("row"),
                            colon: .colonToken(),
                            type: IdentifierTypeSyntax(
                                name: .identifier("Sales")
                            )
                        )
                    },
                    // )
                    rightParen: .rightParenToken()
                )
            )
        }
        
        /// Builds the syntax of the body of an `IfExprSyntax`
        /// - Parameter phi: Source of projected value information
        /// - Returns: The syntax as a `CodeBlockSyntax`
        ///
        /// Builds the following syntax if the projected attributes are `cust`, `avg_1_quant`,
        /// `sum_2_quant`, and `max_3_quant`:
        /// ```swift
        /// let mfStruct = MFStruct(
        ///     cust: row.0,
        ///     avg_1_quant: Average(),
        ///     sum_2_quant: .zero,
        ///     max_3_quant: Double(Int.min)
        /// )
        ///
        /// mfStructs.append(mfStruct)
        /// ```
        private func buildFuncBodySyntax(with phi: Phi) -> CodeBlockSyntax {
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    // let item = MFStruct(...)
                    self.buildMFStructDeclSyntax(with: phi)
                    
                    // mfStructs.append(mfStruct)
                    self.buildMFStructArrAppendSyntax()
                }
            )
        }
        
        /// Builds the syntax for the creation of a `MFStruct` based on decoded data
        /// - Parameter phi: Source of projected value information
        /// - Returns: The syntax as a `VariableDeclSyntax`
        ///
        /// Builds the following syntax if the projected attributes are `cust`, `avg_1_quant`,
        /// `sum_2_quant`, and `max_3_quant`:
        /// ```swift
        /// let mfStruct = MFStruct(
        ///     cust: row.0,
        ///     avg_1_quant: Average(),
        ///     sum_2_quant: .zero,
        ///     max_3_quant: Double(Int.min)
        /// )
        /// ```
        private func buildMFStructDeclSyntax(with phi: Phi) -> VariableDeclSyntax {
            return VariableDeclSyntax(
                // let
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // mfStruct
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("item")
                        ),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                // MFStruct
                                calledExpression: DeclReferenceExprSyntax(
                                    baseName: .identifier("MFStruct")
                                ),
                                // (
                                leftParen: .leftParenToken(),
                                // Parameter Call
                                arguments: LabeledExprListSyntax {
                                    let count = phi.groupByAttributes.count + phi.aggregates.count
                                    
                                    // Loop for Group-By Attributes
                                    for index in 0..<phi.groupByAttributes.count {
                                        let attribute = phi.groupByAttributes[index]
                                        
                                        // In format of:
                                        // <attribute>: row.<num>
                                        LabeledExprSyntax(
                                            leadingTrivia: .newline,
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
                                            trailingComma: index == count - 1 ? nil : .commaToken(),
                                            trailingTrivia: index == count - 1 ? .newline : nil
                                        )
                                    }
                                    
                                    // Loop for Aggregate Functions
                                    for index in 0..<phi.aggregates.count {
                                        let aggregate = phi.aggregates[index]
                                        
                                        // In format of:
                                        // <name>: <defaultValue>
                                        LabeledExprSyntax(
                                            leadingTrivia: .newline,
                                            label: .identifier(aggregate.name),
                                            colon: .colonToken(),
                                            expression: aggregate.function.defaultValueSyntax,
                                            trailingComma: index == phi.aggregates.count - 1 ? nil : .commaToken(),
                                            trailingTrivia: index == phi.aggregates.count - 1 ? .newline : nil
                                        )
                                    }
                                },
                                // )
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds the syntax for append of the newly created `MFStruct`
        /// - Returns: The syntax as a `FunctionCallExprSyntax`
        ///
        /// Builds the following syntax if the projected attributes are `cust`, `avg_1_quant`,
        /// `sum_2_quant`, and `max_3_quant`:
        /// ```swift
        /// results.append(item)
        /// ```
        private func buildMFStructArrAppendSyntax() -> FunctionCallExprSyntax {
            return FunctionCallExprSyntax(
                // mfStructs.append
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier("mfStructs")
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("append")
                    )
                ),
                // (
                leftParen: .leftParenToken(),
                // mfStruct
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier("item")
                        )
                    )
                },
                // )
                rightParen: .rightParenToken()
            )
        }
    }
}
