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
            }
        )
        
        return syntax.formatted().description
    }
}
