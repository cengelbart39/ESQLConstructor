//
//  Aggregate.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/30/24.
//

import Foundation
import SwiftSyntax

/// Represents an expression that uses an Aggregate function
public struct Aggregate: Hashable {
    public let function: AggregateFunction
    public let groupingVarId: String
    public let attribute: String
    
    /// The property name used in `MFStruct` construction
    public var name: String {
        return "\(function.rawValue)_\(groupingVarId)_\(attribute)"
    }
    
    public var type: String {
        switch function {
        case .avg:
            return "Average"
        default:
            return SalesColumn(rawValue: attribute)!.type
        }
    }
}

public extension Array where Element == Aggregate {
    func hasAverage() -> Bool {
        return self.reduce(false) { $0 || $1.function == .avg }
    }
}

/// Represents all possible aggregate functions
public enum AggregateFunction: String, Hashable {
    case max = "max"
    case min = "min"
    case count = "count"
    case sum = "sum"
    case avg = "avg"
    
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
