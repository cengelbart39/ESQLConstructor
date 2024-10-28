//
//  MFStructBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/25/24.
//

import Foundation
import SwiftSyntax

struct MFStructBuilder {
    /**
     Creates a `CodeBlockItemSyntax` for imported modules
     
     Syntax for the following imports:
     ```swift
     import Foundation
     ```
     */
    private func buildImportSyntax() -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                ImportDeclSyntax(
                    path: ImportPathComponentListSyntax {
                        ImportPathComponentSyntax(name: .identifier("Foundation"))
                    },
                    trailingTrivia: .newlines(2)
                )
            )
        )
    }
    
    
    /// Generates a `CodeBlockItemSyntax` for an `MFStruct`
    /// - Parameter phi: Parameters for the Phi operator
    /// - Returns: A `MFStruct` according to the `[ProjectedValue]` in `Phi`
    ///
    /// If ``Phi`` contains the projected values `cust`, `count(1.quant)`, `sum(2.quant)`, and `max(3.quant)`,
    /// it will return a `CodeBlockItemSyntax` for:
    /// ```swift
    /// struct MFStruct {
    ///     let cust: String
    ///     let count_1_quant: Double
    ///     let sum_2_quant: Double
    ///     let max_3_quant: Double
    /// }
    /// ```
    private func buildMFStructSyntax(with phi: Phi) -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                StructDeclSyntax(
                    name: "MFStruct",
                    memberBlock: MemberBlockSyntax(
                        members: MemberBlockItemListSyntax {
                            for value in phi.projectedValues {
                                MemberBlockItemSyntax(
                                    decl: VariableDeclSyntax(
                                        bindingSpecifier: .keyword(.let),
                                        bindings: PatternBindingListSyntax {
                                            PatternBindingSyntax(
                                                pattern: IdentifierPatternSyntax(
                                                    identifier: .identifier(value.name)
                                                ),
                                                typeAnnotation: TypeAnnotationSyntax(
                                                    type: IdentifierTypeSyntax(
                                                        name: .identifier(value.type)
                                                    )
                                                )
                                            )
                                        }
                                    )
                                )
                            }
                        }
                    ),
                    trailingTrivia: .newlines(2)
                )
            )
        )
    }
    
    private func buildArrayExtensionSyntax(with phi: Phi) -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                ExtensionDeclSyntax(
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
                    )
                )
            )
        )
    }
    
    private func buildExistsFunction(with phi: Phi) -> FunctionDeclSyntax {
        return FunctionDeclSyntax(
            name: .identifier("exists"),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax {
                        let attributes = phi.projectedValues.attributes()
                        for index in 0..<attributes.count {
                            FunctionParameterSyntax(
                                firstName: .identifier(attributes[index].name),
                                colon: .colonToken(),
                                type: IdentifierTypeSyntax(
                                    name: .identifier(attributes[index].type)
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
                    CodeBlockItemSyntax(
                        item: CodeBlockItemSyntax.Item(
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
                                                            CodeBlockItemSyntax(
                                                                item: CodeBlockItemSyntax.Item(
                                                                    self.makeFilterExpression(
                                                                        with: phi.projectedValues.attributes()
                                                                    )
                                                                )
                                                            )
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
                        )
                    )
                }
            ),
            trailingTrivia: .newlines(2)
        )
    }
    
    private func makeFilterExpression(with attributes: [ProjectedValue]) -> InfixOperatorExprSyntax {
        if attributes.count == 1 {
            return InfixOperatorExprSyntax(
                leftOperand: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .dollarIdentifier("$0")
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier(attributes[0].name)
                    )
                ),
                operator: BinaryOperatorExprSyntax(
                    operator: .binaryOperator("==")
                ),
                rightOperand: DeclReferenceExprSyntax(
                    baseName: .identifier(attributes[0].name)
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
    
    private func buildFindIndexFunc(with phi: Phi) -> FunctionDeclSyntax {
        return FunctionDeclSyntax(
            name: .identifier("findIndex"),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    leftParen: .leftParenToken(),
                    parameters: FunctionParameterListSyntax {
                        let attributes = phi.projectedValues.attributes()
                        for index in 0..<attributes.count {
                            FunctionParameterSyntax(
                                firstName: .identifier(attributes[index].name),
                                colon: .colonToken(),
                                type: IdentifierTypeSyntax(
                                    name: .identifier(attributes[index].type)
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
                    CodeBlockItemSyntax(
                        item: CodeBlockItemSyntax.Item(
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
                                                        CodeBlockItemSyntax(
                                                            item: CodeBlockItemSyntax.Item(
                                                                self.makeFilterExpression(with: phi.projectedValues.attributes())
                                                            )
                                                        )
                                                    }
                                                )
                                            )
                                        },
                                        rightParen: .rightParenToken()
                                    )
                                )
                            )
                        )
                    )
                }
            )
        )
    }
    
    public func generateSyntax(with phi: Phi) -> String {
        let syntax = SourceFileSyntax(
            statements: CodeBlockItemListSyntax {
                self.buildImportSyntax()
                self.buildMFStructSyntax(with: phi)
                self.buildArrayExtensionSyntax(with: phi)
            }
        )
        
        return syntax.formatted().description
    }
}
