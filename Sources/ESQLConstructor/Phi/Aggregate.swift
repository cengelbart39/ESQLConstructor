//
//  Aggregate.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/30/24.
//

import Foundation
import SwiftSyntax

/// Represents an expression that uses an Aggregate function
public struct Aggregate {
    public let function: AggregateFunction
    public let groupingVarId: String
    public let attribute: String
    
    /// The property name used in `MFStruct` construction
    public var name: String {
        return "\(function.rawValue)_\(groupingVarId)_\(attribute)"
    }
}

/// Represents all possible aggregate functions
public enum AggregateFunction: String {
    case max = "max"
    case min = "min"
    case count = "count"
    case sum = "sum"
    case avg = "avg"
    
    public var defaultSyntax: any ExprSyntaxProtocol {
        switch self {
        case .count, .sum, .avg:
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
