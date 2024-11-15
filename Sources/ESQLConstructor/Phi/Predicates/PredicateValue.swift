//
//  PredicateValue.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/30/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

/// The type of values that can appear in predicates, aside from operators
public indirect enum PredicateValue: CustomDebugStringConvertible {
    case string(String)
    case number(Double)
    case boolean(Bool)
    case date(Date)
    case attribute(String, String)
    case aggregate(any AggregateRepresentable)
    case predicate(Predicate) // Non-parentheses predicate
    case expression(Predicate) // Parentheses predicate
    
    public var debugDescription: String {
        switch self {
        case .string(let string):
            return "'\(string)'"
            
        case .number(let double):
            return String(double)
            
        case .boolean(let bool):
            return String(bool)
            
        case .date(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
            
        case .attribute(let string, let string2):
            return "\(string).\(string2)"
            
        case .aggregate(let aggregate):
            return aggregate.name
            
        case .predicate(let predicate):
            return predicate.debugDescription
            
        case .expression(let predicate):
            return predicate.debugDescription
            
        }
    }
    
    /// Returns the appropriate `PredicateValue` from a `String`
    public static func make(with str: String) -> PredicateValue? {
        if let number = Double(str) {
            return .number(number)
            
        } else if let bool = Bool(str) {
            return .boolean(bool)
            
        } else if str.contains("_") {
            let split = str.split(separator: "_").map({ String($0) })
            
            if split.count == 2 {
                let aggregate =  AttributeAggregate(
                    function: AggregateFunction(rawValue: split[0])!,
                    attribute: split[1]
                )
                return .aggregate(aggregate)
                
            } else {
                let aggregate =  GroupingAggregate(
                    function: AggregateFunction(rawValue: split[0])!,
                    groupingVarId: split[1],
                    attribute: split[2]
                )
                return .aggregate(aggregate)
            }
            
        } else if str.contains(" ") && !str.contains("'") {
            if str.contains("(") && str.contains(")") {
                let split = str.split(separator: " ").map({ String($0) })
                let predicate = Predicate(arr: split)!
                return .expression(predicate)
                
            } else {
                let split = str.split(separator: " ").map({ String($0) })
                let predicate = Predicate(arr: split)!
                return .predicate(predicate)
            }
            
        } else if str.contains(".") {
            let split = str.split(separator: ".").map({ String($0) })
            return .attribute(split[0], split[1])
            
        } else if str.contains("'") {
            let cleaned = str.replacingOccurrences(of: "'", with: "")
            return .string(cleaned)
            
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            if let date = formatter.date(from: str) {
                return .date(date)
                
            } else {
                return nil
            }
        }
    }
    
    /// The equivalent `ExprSyntax` for every `PredicateValue` case
    var syntax: any ExprSyntaxProtocol {
        switch self {
        case .predicate(let predicate):
            return InfixOperatorExprSyntax(
                leftOperand: predicate.value1.syntax,
                operator: BinaryOperatorExprSyntax(text: predicate.operator.swiftEquivalent),
                rightOperand: predicate.value2.syntax
            )
            
        case .expression(let expression):
            return TupleExprSyntax(
                elements: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: InfixOperatorExprSyntax(
                            leftOperand: expression.value1.syntax,
                            operator: BinaryOperatorExprSyntax(text: expression.operator.swiftEquivalent),
                            rightOperand: expression.value2.syntax
                        )
                    )
                }
            )
            
        case .aggregate(let aggregate):
            return MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(
                    baseName: .dollarIdentifier("$0")
                ),
                declName: DeclReferenceExprSyntax(
                    baseName: .identifier(aggregate.name)
                )
            )
            
        case .string(let string):
            return StringLiteralExprSyntax(
                openingQuote: .stringQuoteToken(),
                segments: StringLiteralSegmentListSyntax {
                    StringSegmentSyntax(
                        content: .stringSegment(string)
                    )
                },
                closingQuote: .stringQuoteToken()
            )
            
        case .number(let double):
            return FloatLiteralExprSyntax(
                literal: .floatLiteral("\(double)")
            )
            
        case .boolean(let boolean):
            return BooleanLiteralExprSyntax(boolean)
            
        case .date(let date):
            let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
            
            return ForceUnwrapExprSyntax(
                expression: MemberAccessExprSyntax(
                    base: FunctionCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(
                            baseName: .identifier("DateComponents")
                        ),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax {
                            LabeledExprSyntax(
                                label: .identifier("year"),
                                expression: IntegerLiteralExprSyntax(components.year!),
                                trailingComma: .commaToken()
                            )
                            
                            LabeledExprSyntax(
                                label: .identifier("month"),
                                expression: IntegerLiteralExprSyntax(components.month!),
                                trailingComma: .commaToken()
                            )
                            
                            LabeledExprSyntax(
                                label: .identifier("day"),
                                expression: IntegerLiteralExprSyntax(components.day!)
                            )
                        },
                        rightParen: .rightParenToken()
                    ),
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("date")
                    )
                )
            )
            
        case .attribute(_, let string2):
            return MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(
                    baseName: .identifier("row")
                ),
                declName: DeclReferenceExprSyntax(
                    baseName: .identifier(SalesColumn(rawValue: string2)!.tupleNum)
                )
            )
        }
    }
    
    /// Extracts the ``Predicate`` from ``predicate(_:)`` or ``expression(_:)``; returns `nil` otherwise
    var predicate: Predicate? {
        switch self {
        case .predicate(let predicate), .expression(let predicate):
            return predicate
        default:
            return nil
        }
    }
    
    /// Extracts the ``AggregateRepresentable``s from ``aggregate(_:)``, ``predicate(_:)``, or ``expression(_:)``; otherwise returns an empty array
    var aggregates: [any AggregateRepresentable] {
        switch self {
        case .aggregate(let aggregate):
            return [aggregate]
        case .predicate(let predicate), .expression(let predicate):
            return predicate.value1.aggregates + predicate.value2.aggregates
        default:
            return []
        }
    }
}
