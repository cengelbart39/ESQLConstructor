//
//  AttributeAccess.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 12/13/24.
//  CWID: 10467610
//

import Foundation
import SwiftSyntax

struct AttributeAccess {
    /// Internally, `Int`s are handled as `Double`s. This causes type errors since the schema uses integers and not floats.
    /// This casts any `Int`s as `Double`s when trying to access the value of a row, at any given attribute.
    static func syntax(for attribute: String) -> any ExprSyntaxProtocol {
        if SalesColumn(rawValue: attribute)!.type == .double {
            return FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(
                    baseName: .identifier("Double")
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(
                                baseName: .identifier("row")
                            ),
                            declName: DeclReferenceExprSyntax(
                                baseName: .identifier(SalesColumn(rawValue: attribute)!.tupleNum)
                            )
                        )
                    )
                },
                rightParen: .rightParenToken()
            )
            
        } else {
            return MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(
                    baseName: .identifier("row")
                ),
                declName: DeclReferenceExprSyntax(
                    baseName: .identifier(SalesColumn(rawValue: attribute)!.tupleNum)
                )
            )
        }
    }
}
