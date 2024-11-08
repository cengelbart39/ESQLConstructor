//
//  AggregateFunction.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax

/// Represents all possible aggregate functions
public enum AggregateFunction: String, Hashable {
    case max = "max"
    case min = "min"
    case count = "count"
    case sum = "sum"
    case avg = "avg"
    
    /// Returns the equivalent `ExprSyntax` for each function
    public var defaultSyntax: any ExprSyntaxProtocol {
        switch self {
        case .avg:
            return FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(
                    baseName: .identifier("Average")
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax { },
                rightParen: .rightParenToken()
            )
        case .count, .sum:
            return MemberAccessExprSyntax(
                declName: DeclReferenceExprSyntax(
                    baseName: .identifier("zero")
                )
            )
        case .max:
            return FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(
                    baseName: .identifier("Double")
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(
                                baseName: .identifier("Int")
                            ),
                            declName: DeclReferenceExprSyntax(
                                baseName: .identifier("min")
                            )
                        )
                    )
                },
                rightParen: .rightParenToken()
            )
            
        case .min:
            return FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(
                    baseName: .identifier("Double")
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(
                                baseName: .identifier("Int")
                            ),
                            declName: DeclReferenceExprSyntax(
                                baseName: .identifier("max")
                            )
                        )
                    )
                },
                rightParen: .rightParenToken()
            )
        }
    }
}
