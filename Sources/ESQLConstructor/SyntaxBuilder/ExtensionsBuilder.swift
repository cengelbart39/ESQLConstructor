//
//  ExtensionsBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/14/24.
//

import Foundation
import SwiftSyntax

struct ExtensionsBuilder: SyntaxBuildable {
    typealias Parameter = Void
    
    /// Builds an extension for the `Double` type
    /// - Returns: Syntax as an `ExtensionDeclSyntax`
    ///
    /// Builds the following syntax:
    /// ```swift
    /// extension Double {
    ///     func format() -> String {
    ///         let formatter = NumberFormatter()
    ///         formatter.minimumIntegerDigits = 1
    ///         formatter.maximumFractionDigits = 2
    ///         formatter.minimumFractionDigits = 0
    ///         formatter.usesGroupingSeparator = true
    ///         return formatter.string(from: NSNumber(value: self))!
    ///     }
    /// }
    /// ```
    func buildDoubleExtension() -> ExtensionDeclSyntax {
        return ExtensionDeclSyntax(
            // extension
            extensionKeyword: .keyword(.extension),
            // Double
            extendedType: IdentifierTypeSyntax(
                name: .identifier("Double")
            ),
            memberBlock: MemberBlockSyntax(
                // {
                leftBrace: .leftBraceToken(),
                members: MemberBlockItemListSyntax {
                    MemberBlockItemSyntax(
                        decl: FunctionDeclSyntax(
                            // func
                            funcKeyword: .keyword(.func),
                            // format
                            name: .identifier("format"),
                            // () -> String
                            signature: FunctionSignatureSyntax(
                                parameterClause: FunctionParameterClauseSyntax(
                                    leftParen: .leftParenToken(),
                                    parameters: FunctionParameterListSyntax { },
                                    rightParen: .rightParenToken()
                                ),
                                returnClause: ReturnClauseSyntax(
                                    type: IdentifierTypeSyntax(
                                        name: .identifier("String")
                                    )
                                )
                            ),
                            body: CodeBlockSyntax(
                                // {
                                leftBrace: .leftBraceToken(),
                                statements: CodeBlockItemListSyntax {
                                    // let formatter = NumberFormatter()
                                    VariableDeclSyntax(
                                        bindingSpecifier: .keyword(.let),
                                        bindings: PatternBindingListSyntax {
                                            PatternBindingSyntax(
                                                pattern: IdentifierPatternSyntax(
                                                    identifier: .identifier("formatter")
                                                ),
                                                initializer: InitializerClauseSyntax(
                                                    value: FunctionCallExprSyntax(
                                                        calledExpression: DeclReferenceExprSyntax(
                                                            baseName: .identifier("NumberFormatter")
                                                        ),
                                                        leftParen: .leftParenToken(),
                                                        arguments: LabeledExprListSyntax { },
                                                        rightParen: .rightParenToken()
                                                    )
                                                )
                                            )
                                        }
                                    )
                                    
                                    // formatter.minimumIntegerDigits = 1
                                    InfixOperatorExprSyntax(
                                        leftOperand: MemberAccessExprSyntax(
                                            base: DeclReferenceExprSyntax(
                                                baseName: .identifier("formatter")
                                            ),
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier("minimumIntegerDigits")
                                            )
                                        ),
                                        operator: AssignmentExprSyntax(),
                                        rightOperand: IntegerLiteralExprSyntax(1)
                                    )
                                    
                                    // formatter.maximumFractionDigits = 2
                                    InfixOperatorExprSyntax(
                                        leftOperand: MemberAccessExprSyntax(
                                            base: DeclReferenceExprSyntax(
                                                baseName: .identifier("formatter")
                                            ),
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier("maximumFractionDigits")
                                            )
                                        ),
                                        operator: AssignmentExprSyntax(),
                                        rightOperand: IntegerLiteralExprSyntax(2)
                                    )
                                    
                                    // formatter.minimumFractionDigits = 0
                                    InfixOperatorExprSyntax(
                                        leftOperand: MemberAccessExprSyntax(
                                            base: DeclReferenceExprSyntax(
                                                baseName: .identifier("formatter")
                                            ),
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier("minimumFractionDigits")
                                            )
                                        ),
                                        operator: AssignmentExprSyntax(),
                                        rightOperand: IntegerLiteralExprSyntax(0)
                                    )
                                    
                                    // formatter.usesGroupingSeparator = true
                                    InfixOperatorExprSyntax(
                                        leftOperand: MemberAccessExprSyntax(
                                            base: DeclReferenceExprSyntax(
                                                baseName: .identifier("formatter")
                                            ),
                                            declName: DeclReferenceExprSyntax(
                                                baseName: .identifier("usesGroupingSeparator")
                                            )
                                        ),
                                        operator: AssignmentExprSyntax(),
                                        rightOperand: BooleanLiteralExprSyntax(true)
                                    )
                                    
                                    // return formatter.string(from: NSNumber(value: self))!
                                    ReturnStmtSyntax(
                                        returnKeyword: .keyword(.return),
                                        expression: ForceUnwrapExprSyntax(
                                            expression: FunctionCallExprSyntax(
                                                // formatter.string
                                                calledExpression: MemberAccessExprSyntax(
                                                    base: DeclReferenceExprSyntax(
                                                        baseName: .identifier("formatter")
                                                    ),
                                                    declName: DeclReferenceExprSyntax(
                                                        baseName: .identifier("string")
                                                    )
                                                ),
                                                // (
                                                leftParen: .leftParenToken(),
                                                arguments: LabeledExprListSyntax {
                                                    LabeledExprSyntax(
                                                        // from
                                                        label: .identifier("from"),
                                                        // :
                                                        colon: .colonToken(),
                                                        expression: FunctionCallExprSyntax(
                                                            // NSNumber
                                                            calledExpression: DeclReferenceExprSyntax(
                                                                baseName: .identifier("NSNumber")
                                                            ),
                                                            // (
                                                            leftParen: .leftParenToken(),
                                                            // value: self
                                                            arguments: LabeledExprListSyntax {
                                                                LabeledExprSyntax(
                                                                    label: .identifier("value"),
                                                                    colon: .colonToken(),
                                                                    expression: DeclReferenceExprSyntax(
                                                                        baseName: .keyword(.self)
                                                                    )
                                                                )
                                                            },
                                                            // )
                                                            rightParen: .rightParenToken()
                                                        )
                                                    )
                                                },
                                                // )
                                                rightParen: .rightParenToken()
                                            )
                                        )
                                    )
                                },
                                // }
                                rightBrace: .rightBraceToken()
                            )
                        )
                    )
                },
                // }
                rightBrace: .rightBraceToken()
            )
        )
    }
    
    func generateSyntax(with param: Void = Void()) -> String {
        return self.generateSyntaxBuilder {
            self.buildImportSyntax(.foundation, leadingTrivia: .newlines(2))
            self.buildDoubleExtension()
        }
    }
}
