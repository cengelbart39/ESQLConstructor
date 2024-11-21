//
//  EvaluatorBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/27/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public struct EvaluatorBuilder: SyntaxBuildable {
    public typealias Parameter = Phi
    
    private func buildStructSyntax(with phi: Phi) -> StructDeclSyntax {
        return StructDeclSyntax(
            name: .identifier("Evaluator"),
            memberBlock: MemberBlockSyntax(
                members: MemberBlockItemListSyntax {
                    self.buildPropertySyntax()
                    self.buildInitSyntax()
                    
                    EvaluateFuncBuilder().buildSyntax(with: phi)
                    PopulateFuncBuilder().buildSyntax(with: phi)
                    ComputeFuncBuilder().buildSyntax(with: phi)
                    
                    if let havingPredicate = phi.havingPredicate {
                        HavingFuncBuilder().buildSyntax(with: havingPredicate)
                    }
                }
            )
        )
    }
    
    private func buildPropertySyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("service")
                        ),
                        typeAnnotation: TypeAnnotationSyntax(
                            type: IdentifierTypeSyntax(
                                name: .identifier("PostgresService")
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    private func buildInitSyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: InitializerDeclSyntax(
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        parameters: FunctionParameterListSyntax {
                            FunctionParameterSyntax(
                                firstName: .identifier("service"),
                                type: IdentifierTypeSyntax(
                                    name: .identifier("PostgresService")
                                )
                            )
                        }
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
                                    baseName: .identifier("service")
                                )
                            ),
                            operator: AssignmentExprSyntax(),
                            rightOperand: DeclReferenceExprSyntax(
                                baseName: .identifier("service")
                            )
                        )
                    }
                ),
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    public func generateSyntax(with param: Phi) -> String {
        let foundationImportDecl = self.buildImportSyntax(.foundation)
        let spectreImportDecl = self.buildImportSyntax(.spectreKit, trailingTrivia: .newlines(2))
        let typealiasDecl = SalesTypealiasBuilder().buildSyntax()
        let evaluatorDecl = self.buildStructSyntax(with: param)
        
        return self.generateSyntaxBuilder {
            foundationImportDecl
            spectreImportDecl
            typealiasDecl
            evaluatorDecl
        }
    }
}
