//
//  File.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

struct AverageBuilder: SyntaxBuildable {
    typealias Parameter = Void
    
    /// Generates a `StructDeclSyntax` for the `Average` structure
    /// - Returns: Equivalent `Average` structure
    ///
    /// Builds syntax for the following structure:
    /// ```swift
    /// struct Average: Comparable, CustomStringConvertible, Equatable {
    ///     var sum: Double
    ///     var count: Double
    ///
    ///     var description: String {
    ///         if count != 0 {
    ///             return String(self.calculate())
    ///         } else {
    ///             return "No Data"
    ///         }
    ///     }
    ///
    ///     init() {
    ///         self.sum = 0
    ///         self.count = 0
    ///     }
    ///
    ///     func calculate() -> Double {
    ///         return sum / count
    ///     }
    ///
    ///     static func ==(lhs: Average, rhs: Average) -> Bool {
    ///         return lhs.calculate() == rhs.calculate()
    ///     }
    ///
    ///     static func <(lhs: Average, rhs: Average) -> Bool {
    ///         return lhs.calculate() < rhs.calculate()
    ///     }
    ///
    ///     static func <=(lhs: Average, rhs: Average) -> Bool {
    ///         return lhs.calculate() <= rhs.calculate()
    ///     }
    ///
    ///     static func >(lhs: Average, rhs: Average) -> Bool {
    ///         return lhs.calculate() > rhs.calculate()
    ///     }
    ///
    ///     static func >=(lhs: Average, rhs: Average) -> Bool {
    ///         return lhs.calculate() >= rhs.calculate()
    ///     }
    /// }
    /// ```
    private func buildAverageSyntax() -> StructDeclSyntax {
        return StructDeclSyntax(
            // struct
            structKeyword: .keyword(.struct),
            // Average
            name: .identifier("Average"),
            inheritanceClause: InheritanceClauseSyntax(
                // :
                colon: .colonToken(),
                inheritedTypes: InheritedTypeListSyntax {
                    // Comparable
                    InheritedTypeSyntax(
                        type: IdentifierTypeSyntax(
                            name: .identifier("Comparable")
                        ),
                        trailingComma: .commaToken()
                    )
                    
                    // CustomStringConvertible
                    InheritedTypeSyntax(
                        type: IdentifierTypeSyntax(
                            name: .identifier("CustomStringConvertible")
                        ),
                        trailingComma: .commaToken()
                    )
                    
                    // Equatable
                    InheritedTypeSyntax(
                        type: IdentifierTypeSyntax(
                            name: .identifier("Equatable")
                        )
                    )
                }
            ),
            memberBlock: MemberBlockSyntax(
                members: MemberBlockItemListSyntax {
                    // var sum: Double
                    self.buildPropertySyntax(named: "sum", spacing: false)
                    
                    // var count: Double
                    self.buildPropertySyntax(named: "count", spacing: true)
                    
                    // var description: String
                    self.buildDescriptionSyntax()
                    
                    // init() { ... }
                    self.buildInitSyntax()
                    
                    // calculate() -> Double { ... }
                    self.buildCalculateFuncSyntax()
                    
                    // static func ==(lhs: Average, rhs: Average) -> Bool { ... }
                    self.buildOperatorFuncSyntax(for: "==", spacing: true)
                    
                    // static func <(lhs: Average, rhs: Average) -> Bool { ... }
                    self.buildOperatorFuncSyntax(for: "<", spacing: true)
                    
                    // static func <=(lhs: Average, rhs: Average) -> Bool { ... }
                    self.buildOperatorFuncSyntax(for: "<=", spacing: true)
                    
                    // static func >(lhs: Average, rhs: Average) -> Bool { ... }
                    self.buildOperatorFuncSyntax(for: ">", spacing: true)
                    
                    // static func >=(lhs: Average, rhs: Average) -> Bool { ... }
                    self.buildOperatorFuncSyntax(for: ">=", spacing: false)
                }
            )
        )
    }
    
    /// Builds a `MemberBlockItemSyntax` for one of `Average`'s properties
    /// - Parameters:
    ///   - name: The name of the property
    ///   - spacing: Whether there should be spacing after the item
    /// - Returns: A `MemberBlockItemSyntax` for a variable named `name` of type `Double`
    ///
    /// If `name` is `sum`, the syntax returned is for:
    /// ```swift
    /// var sum: Double
    /// ```
    private func buildPropertySyntax(named name: String, spacing: Bool) -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: VariableDeclSyntax(
                // var
                bindingSpecifier: .keyword(.var),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // <name>
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier(name)
                        ),
                        typeAnnotation: TypeAnnotationSyntax(
                            // :
                            colon: .colonToken(),
                            // Double
                            type: IdentifierTypeSyntax(
                                name: .identifier("Double")
                            )
                        )
                    )
                },
                trailingTrivia: spacing ? .newlines(2) : nil
            )
        )
    }
    
    /// Builds a `MemberBlockItemSyntax` for `Average`'s `description` property
    /// - Returns: The syntax for the `description` property of `Average`
    ///
    /// Builds the syntax for the following computed property:
    /// ```swift
    /// var description: String {
    ///     if count != 0 {
    ///         return String(self.calculate())
    ///     } else {
    ///         return "No Data"
    ///     }
    /// }
    /// ```
    private func buildDescriptionSyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: VariableDeclSyntax(
                // var
                bindingSpecifier: .keyword(.var),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // description
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("description")
                        ),
                        typeAnnotation: TypeAnnotationSyntax(
                            // :
                            colon: .colonToken(),
                            // String
                            type: IdentifierTypeSyntax(
                                name: .identifier("String")
                            )
                        ),
                        accessorBlock: AccessorBlockSyntax(
                            // {
                            leftBrace: .leftBraceToken(),
                            accessors: .getter(
                                CodeBlockItemListSyntax {
                                    ExpressionStmtSyntax(
                                        expression: IfExprSyntax(
                                            // if
                                            ifKeyword: .keyword(.if),
                                            // count != 0
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
                                                // {
                                                leftBrace: .leftBraceToken(),
                                                statements: CodeBlockItemListSyntax {
                                                    ReturnStmtSyntax(
                                                        // return
                                                        returnKeyword: .keyword(.return),
                                                        expression: FunctionCallExprSyntax(
                                                            // String
                                                            calledExpression: DeclReferenceExprSyntax(
                                                                baseName: .identifier("String")
                                                            ),
                                                            // (
                                                            leftParen: .leftParenToken(),
                                                            arguments: LabeledExprListSyntax {
                                                                LabeledExprSyntax(
                                                                    expression: FunctionCallExprSyntax(
                                                                        // self.calculate
                                                                        calledExpression: MemberAccessExprSyntax(
                                                                            base: DeclReferenceExprSyntax(
                                                                                baseName: .keyword(.self)
                                                                            ),
                                                                            declName: DeclReferenceExprSyntax(
                                                                                baseName: .identifier("calculate")
                                                                            )
                                                                        ),
                                                                        // (
                                                                        leftParen: .leftParenToken(),
                                                                        arguments: LabeledExprListSyntax { },
                                                                        // )
                                                                        rightParen: .rightParenToken()
                                                                    )
                                                                )
                                                            },
                                                            // )
                                                            rightParen: .rightParenToken()
                                                        )
                                                    )
                                                },
                                                // }
                                                rightBrace: .rightBraceToken()
                                            ),
                                            // else
                                            elseKeyword: .keyword(.else),
                                            elseBody: IfExprSyntax.ElseBody.codeBlock(
                                                CodeBlockSyntax(
                                                    // {
                                                    leftBrace: .leftBraceToken(),
                                                    statements: CodeBlockItemListSyntax {
                                                        ReturnStmtSyntax(
                                                            // return
                                                            returnKeyword: .keyword(.return),
                                                            // "No Data"
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
                                                    },
                                                    // }
                                                    rightBrace: .rightBraceToken()
                                                )
                                            )
                                        )
                                    )
                                }
                            ),
                            // }
                            rightBrace: .rightBraceToken()
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    /// Builds a `MemberBlockItemSyntax` for `Average`'s `init`
    /// - Returns: The syntax for the `init` of `Average`
    ///
    /// Builds the syntax for the following `init`:
    /// ```swift
    /// init() {
    ///     self.sum = 0
    ///     self.count = 0
    /// }
    /// ```
    private func buildInitSyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: InitializerDeclSyntax(
                // init
                initKeyword: .keyword(.`init`),
                // ()
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        parameters: FunctionParameterListSyntax { }
                    )
                ),
                body: CodeBlockSyntax(
                    // {
                    leftBrace: .leftBraceToken(),
                    statements: CodeBlockItemListSyntax {
                        // self.sum = 0
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
                        
                        // self.count = 0
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
                    },
                    // }
                    rightBrace: .rightBraceToken()
                ),
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    /// Builds a `MemberBlockItemSyntax` for `Average`'s `calculate()` function
    /// - Returns: The syntax for `calculate()`
    ///
    /// Builds the syntax for the following function:
    /// ```swift
    /// func calculate() -> Double {
    ///     return sum / count
    /// }
    /// ```
    private func buildCalculateFuncSyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: FunctionDeclSyntax(
                // calculate
                name: .identifier("calculate"),
                signature: FunctionSignatureSyntax(
                    // ()
                    parameterClause: FunctionParameterClauseSyntax(
                        parameters: FunctionParameterListSyntax { }
                    ),
                    // -> Double
                    returnClause: ReturnClauseSyntax(
                        type: IdentifierTypeSyntax(
                            name: .identifier("Double")
                        )
                    )
                ),
                body: CodeBlockSyntax(
                    // {
                    statements: CodeBlockItemListSyntax {
                        StmtSyntax(
                            // return
                            ReturnStmtSyntax(
                                // sum / count
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
                    }
                    // }
                ),
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    /// Builds a `MemberBlockItemSyntax` for `Average`'s required functions for `Comparable` or `Equatable` conformance
    /// - Parameters:
    ///   - binOp: The binary operator to build the syntax for
    ///   - spacing: Whether to include trailing whitespace after function
    /// - Returns: The `Equatable`- or `Comparable`-conforming function for `binOp`
    ///
    /// If building syntax for the `==` (equal to) operator, returns the following:
    /// ```swift
    /// static func ==(lhs: Average, rhs: Average) -> Bool {
    ///     return lhs.calculate() == rhs.calculate()
    /// }
    /// ```
    private func buildOperatorFuncSyntax(for binOp: String, spacing: Bool) -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: FunctionDeclSyntax(
                // static
                modifiers: DeclModifierListSyntax {
                    DeclModifierSyntax(name: .keyword(.static))
                },
                // func
                funcKeyword: .keyword(.func),
                // <binOp>
                name: .binaryOperator(binOp),
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        // (
                        parameters: FunctionParameterListSyntax {
                            // lhs: Average,
                            FunctionParameterSyntax(
                                firstName: .identifier("lhs"),
                                type: IdentifierTypeSyntax(
                                    name: .identifier("Average")
                                ),
                                trailingComma: .commaToken()
                            )
                            
                            // rhs: Average
                            FunctionParameterSyntax(
                                firstName: .identifier("rhs"),
                                type: IdentifierTypeSyntax(
                                    name: .identifier("Average")
                                )
                            )
                        }
                        // )
                    ),
                    // -> Bool
                    returnClause: ReturnClauseSyntax(
                        type: IdentifierTypeSyntax(
                            name: .identifier("Bool")
                        )
                    )
                ),
                body: CodeBlockSyntax {
                    CodeBlockItemListSyntax {
                        // return
                        ReturnStmtSyntax(
                            expression: InfixOperatorExprSyntax(
                                // lhs.calculate()
                                leftOperand: FunctionCallExprSyntax(
                                    calledExpression: MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax(
                                            baseName: .identifier("lhs")
                                        ),
                                        declName: DeclReferenceExprSyntax(
                                            baseName: .identifier("calculate")
                                        )
                                    ),
                                    leftParen: .leftParenToken(),
                                    arguments: LabeledExprListSyntax { },
                                    rightParen: .rightParenToken()
                                ),
                                // <binOp>
                                operator: BinaryOperatorExprSyntax(text: binOp),
                                // rhs.calculate()
                                rightOperand: FunctionCallExprSyntax(
                                    calledExpression: MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax(
                                            baseName: .identifier("rhs")
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
                        )
                    }
                },
                trailingTrivia: spacing ? .newlines(2) : nil
            )
        )
    }
    
    public func generateSyntax(with param: Void = Void()) -> String {
        let avgDecl = self.buildAverageSyntax()
        
        return self.generateSyntaxBuilder {
            avgDecl
        }
    }
}
