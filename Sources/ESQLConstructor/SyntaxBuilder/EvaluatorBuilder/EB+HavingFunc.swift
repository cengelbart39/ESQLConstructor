//
//  EB+HavingFunc.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/21/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension EvaluatorBuilder {
    struct HavingFuncBuilder {
        /// Builds syntax for a function that applies a having predicate to an array of `MFStruct`
        /// - Parameter predicate: The predicate to apply
        /// - Returns: A `FunctionDeclSyntax` wrapped in a `MemberBlockItemSyntax`
        ///
        /// If there is the following having predicate:
        /// ```sql
        /// sum(1.quant) > 2 * sum(2.quant) or avg(1.quant) > avg(3.quant)
        /// ```
        ///
        /// This function builds the folloqing syntax:
        /// ```swift
        /// private func applyHavingClause(to mfStructs: inout [MFStruct]) {
        ///     mfStructs = mfStructs.filter({
        ///             $0.sum_1_quant > 2.0 * $0.sum_2_quant || $0.avg_1_quant > $0.avg_3_quant
        ///         })
        /// }
        /// ```
        func buildSyntax(with predicate: PredicateValue) -> MemberBlockItemSyntax {
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
                    // applyHavingClause
                    name: .identifier("applyHavingClause"),
                    // (to mfStructs: inout [MFStruct])
                    signature: self.buildFuncSignatureSyntax(),
                    // { ... }
                    body: CodeBlockSyntax(
                        statements: CodeBlockItemListSyntax {
                            self.buildHavingFilterSyntax(predicate)
                        }
                    )
                )
            )
        }
        
        /// Builds the function signature of `applyHavingClause(to:)`.
        /// - Returns: Syntax as `FunctionSignatureSyntax`
        ///
        /// Builds the following syntax:
        /// ```swift
        /// (to mfStructs: inout [MFStruct])
        /// ```
        private func buildFuncSignatureSyntax() -> FunctionSignatureSyntax {
            return FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    // (
                    leftParen: .leftParenToken(),
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            // to
                            firstName: .identifier("to"),
                            // mfStructs
                            secondName: .identifier("mfStructs"),
                            // :
                            colon: .colonToken(),
                            type: AttributedTypeSyntax(
                                // inout
                                specifiers: TypeSpecifierListSyntax {
                                    SimpleTypeSpecifierSyntax(
                                        specifier: .keyword(.inout)
                                    )
                                },
                                // [MFStruct]
                                baseType: ArrayTypeSyntax(
                                    element: IdentifierTypeSyntax(
                                        name: .identifier("MFStruct")
                                    )
                                )
                            )
                        )
                    },
                    // )
                    rightParen: .rightParenToken()
                )
            )
        }
        
        /// Builds the syntax for a filter function call that applies a having predicate
        /// - Parameter havingPredicate: The predicate to apply
        /// - Returns: Builds syntax as a `InfixOperatorExprSyntax`
        ///
        /// If there is the following having predicate:
        /// ```sql
        /// sum(1.quant) > 2 * sum(2.quant) or avg(1.quant) > avg(3.quant)
        /// ```
        ///
        /// This function builds the folloqing syntax:
        /// ```swift
        /// mfStructs = mfStructs.filter({
        ///         $0.sum_1_quant > 2.0 * $0.sum_2_quant || $0.avg_1_quant > $0.avg_3_quant
        ///     })
        /// ```
        private func buildHavingFilterSyntax(_ havingPredicate: PredicateValue) -> InfixOperatorExprSyntax {
            return InfixOperatorExprSyntax(
                // output
                leftOperand: DeclReferenceExprSyntax(
                    baseName: .identifier("mfStructs")
                ),
                // =
                operator: AssignmentExprSyntax(),
                rightOperand: FunctionCallExprSyntax(
                    // output.filter
                    calledExpression: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(
                            baseName: .identifier("mfStructs")
                        ),
                        declName: DeclReferenceExprSyntax(
                            baseName: .identifier("filter")
                        )
                    ),
                    // (
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax {
                        LabeledExprSyntax(
                            expression: ClosureExprSyntax(
                                // {
                                leftBrace: .leftBraceToken(),
                                // $0.sum_1_quant > 2.0 * $0.sum_2_quant || $0.avg_1_quant > $0.avg_3_quant (in example)
                                statements: CodeBlockItemListSyntax {
                                    havingPredicate.syntax
                                },
                                // }
                                rightBrace: .rightBraceToken()
                            )
                        )
                    },
                    // )
                    rightParen: .rightParenToken(),
                    trailingTrivia: .newlines(2)
                )
            )
        }
    }
}
