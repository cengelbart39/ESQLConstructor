//
//  MFSB+ArrayExt.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public extension MFStructBuilder {
    struct ArrayExtBuilder {
        /// Builds a `ExtensionDeclSyntax` for `MFStruct` array extensions
        /// - Parameter phi: Parameters of the `Phi` operator
        /// - Returns: Array extensions according to `groupByAttributes` in `Phi`
        ///
        /// If ``Phi`` contains the projected values `cust`, `count(1.quant)`, `sum(2.quant)`, and `max(3.quant)`,
        /// it will return a `ExtensionDeclSyntax` for:
        /// ```swift
        /// extension Array where Element == MFStruct {
        ///     func exists(cust: String) -> Bool {
        ///         return self.filter({ $0.cust == cust }).count == 1
        ///     }
        ///
        ///     func findIndex(cust: String) -> Int {
        ///         return self.firstIndex(where: { $0.cust == cust })!
        ///     }
        /// }
        /// ```
        public func buildSyntax(with phi: Phi) -> ExtensionDeclSyntax {
            return ExtensionDeclSyntax(
                extendedType: IdentifierTypeSyntax(
                    name: .identifier("Array")
                ),
                genericWhereClause: GenericWhereClauseSyntax(
                    requirements: GenericRequirementListSyntax {
                        GenericRequirementSyntax(
                            requirement: .sameTypeRequirement(
                                SameTypeRequirementSyntax(
                                    leftType: IdentifierTypeSyntax(
                                        name: .identifier("Element")
                                    ),
                                    equal: .binaryOperator("=="),
                                    rightType: IdentifierTypeSyntax(
                                        name: .identifier("MFStruct")
                                    )
                                )
                            )
                        )
                    }
                ),
                memberBlock: MemberBlockSyntax(
                    members: MemberBlockItemListSyntax {
                        self.buildExistsFunction(with: phi)
                        self.buildFindIndexFunc(with: phi)
                    }
                ),
                trailingTrivia: phi.aggregates.hasAverage() ? .newlines(2) : nil
            )
        }
        
        /// Builds a `FunctionDeclSyntax` for the `exists()` function, to determine if a `MFStruct` has
        /// specified values for the grouping attributes
        /// - Parameter phi: Parameters of the `Phi` operator
        /// - Returns: A function with varying parameters and `filter` body according to `groupByAttributes` in `Phi`
        ///
        /// If ``Phi`` contains the projected values `cust`, `count(1.quant)`, `sum(2.quant)`, and `max(3.quant)`,
        /// it will return a `FunctionDeclSyntax` for:
        /// ```swift
        /// func exists(cust: String) -> Bool {
        ///     return self.filter({ $0.cust == cust }).count == 1
        /// }
        /// ```
        private func buildExistsFunction(with phi: Phi) -> FunctionDeclSyntax {
            return FunctionDeclSyntax(
                name: .identifier("exists"),
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        parameters: FunctionParameterListSyntax {
                            let attributes = phi.groupByAttributes
                            for index in 0..<attributes.count {
                                FunctionParameterSyntax(
                                    firstName: .identifier(attributes[index]),
                                    colon: .colonToken(),
                                    type: IdentifierTypeSyntax(
                                        name: .identifier(SalesColumn(rawValue: attributes[index])!.type.rawValue)
                                    ),
                                    trailingComma: index == attributes.endIndex - 1 ? nil : .commaToken()
                                )
                            }
                        }
                    ),
                    returnClause: ReturnClauseSyntax(
                        type: IdentifierTypeSyntax(
                            name: .identifier("Bool")
                        )
                    )
                ),
                body: CodeBlockSyntax(
                    statements: CodeBlockItemListSyntax {
                        ReturnStmtSyntax(
                            expression: InfixOperatorExprSyntax(
                                leftOperand: MemberAccessExprSyntax(
                                    base: FunctionCallExprSyntax(
                                        calledExpression: MemberAccessExprSyntax(
                                            base: DeclReferenceExprSyntax(
                                                baseName: .keyword(.self)
                                            ),
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier("filter")
                                            )
                                        ),
                                        leftParen: .leftParenToken(),
                                        arguments: LabeledExprListSyntax {
                                            LabeledExprSyntax(
                                                expression: ClosureExprSyntax(
                                                    statements: CodeBlockItemListSyntax {
                                                        self.makeFilterExpression(with: phi.groupByAttributes)
                                                    }
                                                )
                                            )
                                        },
                                        rightParen: .rightParenToken()
                                    ),
                                    declName: DeclReferenceExprSyntax(
                                        baseName: .identifier("count")
                                    )
                                ),
                                operator: BinaryOperatorExprSyntax(
                                    operator: .binaryOperator("==")
                                ),
                                rightOperand: IntegerLiteralExprSyntax(1)
                            )
                        )
                    }
                ),
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds a `FunctionDeclSyntax` for the `findIndex()` function, to get the index for a `MFStruct`
        /// with matching values for the grouping attributes
        /// - Parameter phi: Parameters of the `Phi` operator
        /// - Returns: A function with varying parameters and `firstIndex` body according to `groupByAttributes` in `Phi`
        ///
        /// If ``Phi`` contains the projected values `cust`, `count(1.quant)`, `sum(2.quant)`, and `max(3.quant)`,
        /// it will return a `FunctionDeclSyntax` for:
        /// ```swift
        /// func findIndex(cust: String) -> Int {
        ///     return self.firstIndex(where: { $0.cust == cust })!
        /// }
        /// ```
        private func buildFindIndexFunc(with phi: Phi) -> FunctionDeclSyntax {
            return FunctionDeclSyntax(
                name: .identifier("findIndex"),
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        leftParen: .leftParenToken(),
                        parameters: FunctionParameterListSyntax {
                            let attributes = phi.groupByAttributes
                            for index in 0..<attributes.count {
                                FunctionParameterSyntax(
                                    firstName: .identifier(attributes[index]),
                                    colon: .colonToken(),
                                    type: IdentifierTypeSyntax(
                                        name: .identifier(SalesColumn(rawValue: attributes[index])!.type.rawValue)
                                    ),
                                    trailingComma: index == attributes.count - 1 ? nil : .commaToken()
                                )
                            }
                        },
                        rightParen: .rightParenToken()
                    ),
                    returnClause: ReturnClauseSyntax(
                        type: IdentifierTypeSyntax(
                            name: .identifier("Int")
                        )
                    )
                ),
                body: CodeBlockSyntax(
                    statements: CodeBlockItemListSyntax {
                        ReturnStmtSyntax(
                            expression: ForceUnwrapExprSyntax(
                                expression: FunctionCallExprSyntax(
                                    calledExpression: MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax(
                                            baseName: .keyword(.self)
                                        ),
                                        declName: DeclReferenceExprSyntax(
                                            baseName: .identifier("firstIndex")
                                        )
                                    ),
                                    leftParen: .leftParenToken(),
                                    arguments: LabeledExprListSyntax {
                                        LabeledExprSyntax(
                                            label: .identifier("where"),
                                            colon: .colonToken(),
                                            expression: ClosureExprSyntax(
                                                statements: CodeBlockItemListSyntax {
                                                    self.makeFilterExpression(with: phi.groupByAttributes)
                                                }
                                            )
                                        )
                                    },
                                    rightParen: .rightParenToken()
                                )
                            )
                        )
                    }
                )
            )
        }
        
        /// Builds the boolean expression to match all grouping attributes.
        /// - Parameter attributes: All group-by attributes that need to be matched
        /// - Returns: The equivalent `InfixOperatorExprSyntax` for all attributes
        ///
        /// If the group-by attributes are `cust` and `quant`, this function returns the equivalent `InfixOperatorExprSyntax` for:
        /// ```swift
        /// $0.cust == cust && $0.quant == quant
        /// ```
        /// - SeeAlso: This function builds the expression to condition on for ``buildExistsFunction(with:)`` and ``buildFindIndexFunc(with:)``
        private func makeFilterExpression(with attributes: [String]) -> InfixOperatorExprSyntax {
            if attributes.count == 1 {
                return InfixOperatorExprSyntax(
                    leftOperand: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(
                            baseName: .dollarIdentifier("$0")
                        ),
                        declName: DeclReferenceExprSyntax(
                            baseName: .identifier(attributes[0])
                        )
                    ),
                    operator: BinaryOperatorExprSyntax(
                        operator: .binaryOperator("==")
                    ),
                    rightOperand: DeclReferenceExprSyntax(
                        baseName: .identifier(attributes[0])
                    )
                )
                
            } else {
                var rest = attributes
                let last = rest.remove(at: attributes.count - 1)
                
                return InfixOperatorExprSyntax(
                    leftOperand: self.makeFilterExpression(with: rest),
                    operator: BinaryOperatorExprSyntax(
                        operator: .binaryOperator("&&")
                    ),
                    rightOperand: self.makeFilterExpression(with: [last])
                )
            }
        }
    }
}
