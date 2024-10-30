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
                                        bindingSpecifier: value.isAttribute ? .keyword(.let) : .keyword(.var),
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
                    ),
                    trailingTrivia: phi.projectedValues.hasAverage() ? .newlines(2) : nil
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
    
    private func buildAverageSyntax() -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: .decl(
                DeclSyntax(
                    StructDeclSyntax(
                        name: .identifier("Average"),
                        inheritanceClause: InheritanceClauseSyntax(
                            inheritedTypes: InheritedTypeListSyntax {
                                InheritedTypeSyntax(
                                    type: IdentifierTypeSyntax(
                                        name: .identifier("CustomStringConvertible")
                                    )
                                )
                            }
                        ),
                        memberBlock: MemberBlockSyntax(
                            members: MemberBlockItemListSyntax {
                                MemberBlockItemSyntax(
                                    decl: VariableDeclSyntax(
                                        bindingSpecifier: .keyword(.var),
                                        bindings: PatternBindingListSyntax {
                                            PatternBindingSyntax(
                                                pattern: IdentifierPatternSyntax(
                                                    identifier: .identifier("sum")
                                                ),
                                                typeAnnotation: TypeAnnotationSyntax(
                                                    colon: .colonToken(),
                                                    type: IdentifierTypeSyntax(
                                                        name: .identifier("Double")
                                                    )
                                                )
                                            )
                                        }
                                    )
                                )
                                
                                MemberBlockItemSyntax(
                                    decl: VariableDeclSyntax(
                                        bindingSpecifier: .keyword(.var),
                                        bindings: PatternBindingListSyntax {
                                            PatternBindingSyntax(
                                                pattern: IdentifierPatternSyntax(
                                                    identifier: .identifier("count")
                                                ),
                                                typeAnnotation: TypeAnnotationSyntax(
                                                    colon: .colonToken(),
                                                    type: IdentifierTypeSyntax(
                                                        name: .identifier("Double")
                                                    )
                                                )
                                            )
                                        },
                                        trailingTrivia: .newlines(2)
                                    )
                                )
                                
                                MemberBlockItemSyntax(
                                    decl: VariableDeclSyntax(
                                        bindingSpecifier: .keyword(.var),
                                        bindings: PatternBindingListSyntax {
                                            PatternBindingSyntax(
                                                pattern: IdentifierPatternSyntax(
                                                    identifier: .identifier("description")
                                                ),
                                                typeAnnotation: TypeAnnotationSyntax(
                                                    colon: .colonToken(),
                                                    type: IdentifierTypeSyntax(
                                                        name: .identifier("String")
                                                    )
                                                ),
                                                accessorBlock: AccessorBlockSyntax(
                                                    accessors: .getter(
                                                        CodeBlockItemListSyntax {
                                                            ExpressionStmtSyntax(
                                                                expression: IfExprSyntax(
                                                                    conditions: ConditionElementListSyntax {
                                                                        ConditionElementSyntax(
                                                                            condition: .expression(
                                                                                ExprSyntax(
                                                                                    InfixOperatorExprSyntax(
                                                                                        leftOperand: DeclReferenceExprSyntax(
                                                                                            baseName: .identifier("count")
                                                                                        ),
                                                                                        operator: BinaryOperatorExprSyntax(text: "!="),
                                                                                        rightOperand: IntegerLiteralExprSyntax(0)
                                                                                    )
                                                                                )
                                                                            )
                                                                        )
                                                                    },
                                                                    body: CodeBlockSyntax(
                                                                        statements: CodeBlockItemListSyntax {
                                                                            ReturnStmtSyntax(
                                                                                expression: FunctionCallExprSyntax(
                                                                                    calledExpression: DeclReferenceExprSyntax(
                                                                                        baseName: .identifier("String")
                                                                                    ),
                                                                                    leftParen: .leftParenToken(),
                                                                                    arguments: LabeledExprListSyntax {
                                                                                        LabeledExprSyntax(
                                                                                            expression: FunctionCallExprSyntax(
                                                                                                calledExpression: MemberAccessExprSyntax(
                                                                                                    base: DeclReferenceExprSyntax(
                                                                                                        baseName: .keyword(.self)
                                                                                                    ),
                                                                                                    declName: DeclReferenceExprSyntax(
                                                                                                        baseName: .identifier("calculate")
                                                                                                    )
                                                                                                ),
                                                                                                leftParen: .leftParenToken(),
                                                                                                arguments: LabeledExprListSyntax { },
                                                                                                rightParen: .rightParenToken()
                                                                                            )
                                                                                        )
                                                                                    },
                                                                                    rightParen: .rightParenToken()
                                                                                )
                                                                            )
                                                                        }
                                                                    ),
                                                                    elseKeyword: .keyword(.else),
                                                                    elseBody: IfExprSyntax.ElseBody.codeBlock(
                                                                        CodeBlockSyntax(
                                                                            statements: CodeBlockItemListSyntax {
                                                                                ReturnStmtSyntax(
                                                                                    expression: StringLiteralExprSyntax(
                                                                                        openingQuote: .stringQuoteToken(),
                                                                                        segments: StringLiteralSegmentListSyntax {
                                                                                            StringSegmentSyntax(
                                                                                                content: .stringSegment("No Data")
                                                                                            )
                                                                                        },
                                                                                        closingQuote: .stringQuoteToken()
                                                                                    )
                                                                                )
                                                                            }
                                                                        )
                                                                    )
                                                                )
                                                            )
                                                        }
                                                    )
                                                )
                                            )
                                        },
                                        trailingTrivia: .newlines(2)
                                    )
                                )
                                
                                MemberBlockItemSyntax(
                                    decl: InitializerDeclSyntax(
                                        signature: FunctionSignatureSyntax(
                                            parameterClause: FunctionParameterClauseSyntax(
                                                parameters: FunctionParameterListSyntax { }
                                            )
                                        ),
                                        body: CodeBlockSyntax(
                                            statements: CodeBlockItemListSyntax {
                                                InfixOperatorExprSyntax(
                                                    leftOperand: MemberAccessExprSyntax(
                                                        base: DeclReferenceExprSyntax(
                                                            baseName: .keyword(.self)
                                                        ),
                                                        declName: DeclReferenceExprSyntax(
                                                            baseName: .identifier("sum")
                                                        )
                                                    ),
                                                    operator: AssignmentExprSyntax(),
                                                    rightOperand: IntegerLiteralExprSyntax(0)
                                                )
                                                
                                                InfixOperatorExprSyntax(
                                                    leftOperand: MemberAccessExprSyntax(
                                                        base: DeclReferenceExprSyntax(
                                                            baseName: .keyword(.self)
                                                        ),
                                                        declName: DeclReferenceExprSyntax(
                                                            baseName: .identifier("count")
                                                        )
                                                    ),
                                                    operator: AssignmentExprSyntax(),
                                                    rightOperand: IntegerLiteralExprSyntax(0)
                                                )
                                            }
                                        ),
                                        trailingTrivia: .newlines(2)
                                    )
                                )
                                
                                MemberBlockItemSyntax(
                                    decl: FunctionDeclSyntax(
                                        name: .identifier("calculate"),
                                        signature: FunctionSignatureSyntax(
                                            parameterClause: FunctionParameterClauseSyntax(
                                                parameters: FunctionParameterListSyntax { }
                                            ),
                                            returnClause: ReturnClauseSyntax(
                                                type: IdentifierTypeSyntax(
                                                    name: .identifier("Double")
                                                )
                                            )
                                        ),
                                        body: CodeBlockSyntax(
                                            statements: CodeBlockItemListSyntax {
                                                CodeBlockItemSyntax(
                                                    item: .stmt(
                                                        StmtSyntax(
                                                            ReturnStmtSyntax(
                                                                expression: InfixOperatorExprSyntax(
                                                                    leftOperand: DeclReferenceExprSyntax(
                                                                        baseName: .identifier("sum")
                                                                    ),
                                                                    operator: BinaryOperatorExprSyntax(
                                                                        operator: .binaryOperator("/")
                                                                    ),
                                                                    rightOperand: DeclReferenceExprSyntax(
                                                                        baseName: .identifier("count")
                                                                    )
                                                                )
                                                            )
                                                        )
                                                    )
                                                )
                                            }
                                        )
                                    )
                                )

                            }
                        )
                    )
                )
            )
        )
    }
    
    public func generateSyntax(with phi: Phi) -> String {
        let syntax = SourceFileSyntax(
            statements: CodeBlockItemListSyntax {
                self.buildImportSyntax()
                self.buildMFStructSyntax(with: phi)
                self.buildArrayExtensionSyntax(with: phi)
                
                if phi.projectedValues.hasAverage() {
                    self.buildAverageSyntax()
                }
            }
        )
        
        return syntax.formatted().description
    }
}
