//
//  MainBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/27/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public struct MainBuilder {
    private func buildImportSyntax() -> [CodeBlockItemSyntax] {
        let argumentParserImport = CodeBlockItemSyntax(
            item: .decl(DeclSyntax(
                ImportDeclSyntax(
                    path: ImportPathComponentListSyntax {
                        ImportPathComponentSyntax(
                            name: .identifier("ArgumentParser")
                        )
                    }
                )
            ))
        )
        
        let foundationImport = CodeBlockItemSyntax(
            item: .decl(DeclSyntax(
                ImportDeclSyntax(
                    path: ImportPathComponentListSyntax {
                        ImportPathComponentSyntax(
                            name: .identifier("Foundation")
                        )
                    },
                    trailingTrivia: .newlines(2)
                )
            ))
        )
        
        return [argumentParserImport, foundationImport]
    }
    
    func buildStructSyntax() -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                StructDeclSyntax(
                    attributes: AttributeListSyntax {
                        AttributeSyntax(
                            attributeName: IdentifierTypeSyntax(
                                name: .identifier("main")
                            )
                        )
                    },
                    name: .identifier("ESQLEvaluator"),
                    inheritanceClause: InheritanceClauseSyntax(
                        inheritedTypes: InheritedTypeListSyntax {
                            InheritedTypeSyntax(
                                type: IdentifierTypeSyntax(
                                    name: .identifier("AsyncParsableCommand")
                                )
                            )
                        }
                    ),
                    memberBlock: MemberBlockSyntax(
                        members: MemberBlockItemListSyntax {
                            self.buildCommandConfigSyntax()
                            self.buildRunFunc()
                        }
                    )
                )
            )
        )
    }
    
    private func buildCommandConfigSyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: VariableDeclSyntax(
                modifiers: DeclModifierListSyntax {
                    DeclModifierSyntax(
                        name: .keyword(.static)
                    )
                },
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("configuration")
                        ),
                        initializer: InitializerClauseSyntax(
                            value: FunctionCallExprSyntax(
                                calledExpression: DeclReferenceExprSyntax(
                                    baseName: .identifier("CommandConfiguration")
                                ),
                                leftParen: .leftParenToken(),
                                arguments: LabeledExprListSyntax {
                                    LabeledExprSyntax(
                                        label: .identifier("abstract"),
                                        colon: .colonToken(),
                                        expression: StringLiteralExprSyntax(
                                            openingQuote: .stringQuoteToken(),
                                            segments: StringLiteralSegmentListSyntax {
                                                StringSegmentSyntax(
                                                    content: .stringSegment("A utility that runs the result of a ESQL Phi Operator. Constructed by ESQLConstructor.")
                                                )
                                            },
                                            closingQuote: .stringQuoteToken()
                                        ),
                                        trailingComma: .commaToken()
                                    )
                                    
                                    LabeledExprSyntax(
                                        label: .identifier("version"),
                                        colon: .colonToken(),
                                        expression: StringLiteralExprSyntax(
                                            openingQuote: .stringQuoteToken(),
                                            segments: StringLiteralSegmentListSyntax {
                                                StringSegmentSyntax(
                                                    content: .stringSegment("1.0.0")
                                                )
                                            },
                                            closingQuote: .stringQuoteToken()
                                        )
                                    )
                                },
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    private func buildRunFunc() -> MemberBlockItemSyntax {
        MemberBlockItemSyntax(
            decl: FunctionDeclSyntax(
                name: .identifier("run"),
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        parameters: FunctionParameterListSyntax { }
                    ),
                    effectSpecifiers: FunctionEffectSpecifiersSyntax(
                        asyncSpecifier: .keyword(.async),
                        throwsClause: ThrowsClauseSyntax(
                            throwsSpecifier: .keyword(.throws)
                        )
                    )
                ),
                body: CodeBlockSyntax(
                    statements: CodeBlockItemListSyntax {
                        CodeBlockItemSyntax(
                            item: CodeBlockItemSyntax.Item(
                                VariableDeclSyntax(
                                    bindingSpecifier: .keyword(.let),
                                    bindings: PatternBindingListSyntax {
                                        PatternBindingSyntax(
                                            pattern: IdentifierPatternSyntax(
                                                identifier: .identifier("service")
                                            ),
                                            initializer: InitializerClauseSyntax(
                                                value: FunctionCallExprSyntax(
                                                    calledExpression: DeclReferenceExprSyntax(
                                                        baseName: .identifier("PostgresService")
                                                    ),
                                                    leftParen: .leftParenToken(),
                                                    arguments: LabeledExprListSyntax { },
                                                    rightParen: .rightParenToken()
                                                )
                                            )
                                        )
                                    }
                                )
                            )
                        )
                        
                        CodeBlockItemSyntax(
                            item: CodeBlockItemSyntax.Item(
                                VariableDeclSyntax(
                                    bindingSpecifier: .keyword(.let),
                                    bindings: PatternBindingListSyntax {
                                        PatternBindingSyntax(
                                            pattern: IdentifierPatternSyntax(
                                                identifier: .identifier("evaluator")
                                            ),
                                            initializer: InitializerClauseSyntax(
                                                value: FunctionCallExprSyntax(
                                                    calledExpression: DeclReferenceExprSyntax(
                                                        baseName: .identifier("Evaluator")
                                                    ),
                                                    leftParen: .leftParenToken(),
                                                    arguments: LabeledExprListSyntax {
                                                        LabeledExprSyntax(
                                                            label: .identifier("service"),
                                                            colon: .colonToken(),
                                                            expression: DeclReferenceExprSyntax(
                                                                baseName: .identifier("service")
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
                        )
                        
                        CodeBlockItemSyntax(
                            item: CodeBlockItemSyntax.Item(
                                VariableDeclSyntax(
                                    bindingSpecifier: .keyword(.let),
                                    bindings: PatternBindingListSyntax {
                                        PatternBindingSyntax(
                                            pattern: IdentifierPatternSyntax(
                                                identifier: .identifier("mfStruct")
                                            ),
                                            initializer: InitializerClauseSyntax(
                                                value: TryExprSyntax(
                                                    expression: AwaitExprSyntax(
                                                        expression: FunctionCallExprSyntax(
                                                            calledExpression: MemberAccessExprSyntax(
                                                                base: DeclReferenceExprSyntax(
                                                                    baseName: .identifier("evaluator")
                                                                ),
                                                                declName: DeclReferenceExprSyntax(
                                                                    baseName: .identifier("populateMFStruct")
                                                                )
                                                            ),
                                                            leftParen: .leftParenToken(),
                                                            arguments: LabeledExprListSyntax { },
                                                            rightParen: .rightParenToken()
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
    }
    
    public func generateSyntax() -> String {
        let imports = self.buildImportSyntax()
        
        let syntax = SourceFileSyntax(
            statements: CodeBlockItemListSyntax {
                imports[0]
                imports[1]
                self.buildStructSyntax()
            }
        )
        
        return syntax.formatted().description
    }
}
