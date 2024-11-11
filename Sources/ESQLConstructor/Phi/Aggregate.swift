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
    
    /// The type, as a `String`, that the aggregate function returns
    public var type: String {
        switch function {
        case .avg:
            return "Average"
        default:
            return SalesColumn(rawValue: attribute)!.type
        }
    }
    
    /// Builds a syntax to update an aggregate calculation with
    /// - Parameter overwrite: When exists, overwrites the ``AggregateFunction``; primarily used for average calculations
    /// - Returns: The appropriate `ExprSyntaxProtocol` for the aggregate
    ///
    /// Builds the following syntax:
    /// * If ``AggregateFunction/count``:
    /// ```swift
    /// 1
    /// ```
    /// * If ``AggregateFunction/sum`` or ``AggregateFunction/avg``:
    /// ```swift
    /// Double(row.<num>)
    /// ```
    /// * If ``AggregateFunction/max``:
    /// ```swift
    /// max(output[index].<aggregate>, Double(row.<num>))
    /// ```
    /// * If ``AggregateFunction/min``:
    /// ```swift
    /// min(output[index].<aggregate>, Double(row.<num>))
    /// ```
    public func updateSyntax(overwrite: AggregateFunction? = nil) -> any ExprSyntaxProtocol {
        switch overwrite ?? self.function {
        case .count:
            return IntegerLiteralExprSyntax(literal: .integerLiteral("1"))
            
        case .sum, .avg:
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
                                baseName: .identifier(SalesColumn(rawValue: self.attribute)!.tupleNum)
                            )
                        )
                    )
                },
                rightParen: .rightParenToken()
            )
            
        case .max, .min:
            return FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(
                    baseName: .identifier(self.function == .max ? "max" : "min")
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: MemberAccessExprSyntax(
                            base: SubscriptCallExprSyntax(
                                calledExpression: DeclReferenceExprSyntax(
                                    baseName: .identifier("output")
                                ),
                                arguments: LabeledExprListSyntax {
                                    LabeledExprSyntax(
                                        expression: DeclReferenceExprSyntax(
                                            baseName: .identifier("index")
                                        )
                                    )
                                }
                            ),
                            declName: DeclReferenceExprSyntax(
                                baseName: .identifier(self.name)
                            )
                        ),
                        trailingComma: .commaToken()
                    )
                    
                    LabeledExprSyntax(
                        expression: FunctionCallExprSyntax(
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
                                            baseName: .identifier(SalesColumn(rawValue: self.attribute)!.tupleNum)
                                        )
                                    )
                                )
                            },
                            rightParen: .rightParenToken()
                        )
                    )
                },
                rightParen: .rightParenToken()
            )
        }
    }
}

public extension Array where Element == Aggregate {
    /// Determines if an array contains at least 1 average aggregate
    /// - Returns: Whether an array contains at least 1 average aggregate
    func hasAverage() -> Bool {
        return self.reduce(false) { $0 || $1.function == .avg }
    }
}
