//
//  MFStructBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/25/24.
//  CWID: 10467610
//

import Foundation
import SwiftSyntax

public struct MFStructBuilder: SyntaxBuildable {
    public typealias Parameter = Phi
    
    /// Builds a `StructDeclSyntax` for an `MFStruct`
    /// - Parameter phi: Parameters for the Phi operator
    /// - Returns: A `MFStruct` according to the `groupByAttributes` and `aggregates` in `Phi`
    ///
    /// If ``Phi`` contains the projected values `cust`, `count(1.quant)`, `sum(2.quant)`, and `max(3.quant)`,
    /// it will return a `StructDeclSyntax` for:
    /// ```swift
    /// struct MFStruct {
    ///     let cust: String
    ///     let count_1_quant: Double
    ///     let sum_2_quant: Double
    ///     let max_3_quant: Double
    /// }
    /// ```
    private func buildMFStructSyntax(with phi: Phi) -> StructDeclSyntax {
        return StructDeclSyntax(
            name: "MFStruct",
            memberBlock: MemberBlockSyntax(
                members: MemberBlockItemListSyntax {
                    for value in phi.groupByAttributes {
                        self.buildVariableDeclSyntax(
                            .keyword(.let),
                            named: value,
                            of: SalesColumn(rawValue: value)!.type.rawValue
                        )
                    }
                    
                    for value in phi.aggregates {
                        self.buildVariableDeclSyntax(
                            .keyword(.var),
                            named: value.name,
                            of: value.type.rawValue
                        )
                    }
                }
            ),
            trailingTrivia: .newlines(2)
        )
    }
    
    /// Builds a `MemberBlockItemSyntax` with a specified binding, name, and type
    /// - Parameters:
    ///   - specififer: Some `TokenSyntax`; assumed to be `TokenSyntax/keyword(_:)`
    ///   - name: The name of the variable
    ///   - type: The type of the variable
    /// - Returns: The appropriate `VariableDeclSyntax` wrapped in a `MemberBlockItemSyntax`
    private func buildVariableDeclSyntax(
        _ specififer: TokenSyntax,
        named name: String,
        of type: String
    ) -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: VariableDeclSyntax(
                bindingSpecifier: specififer,
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier(name)
                        ),
                        typeAnnotation: TypeAnnotationSyntax(
                            type: IdentifierTypeSyntax(
                                name: .identifier(type)
                            )
                        )
                    )
                }
            )
        )
    }
    
    public func generateSyntax(with param: Phi) -> String {
        let importStmt = self.buildImportSyntax(.foundation, leadingTrivia: self.commentHeader, trailingTrivia: .newlines(2))
        let mfStructDecl = self.buildMFStructSyntax(with: param)
        let arrayExtDecl = ArrayExtBuilder().buildSyntax(with: param)
        
        return self.generateSyntaxBuilder {
            importStmt
            mfStructDecl
            arrayExtDecl
        }
    }
}
