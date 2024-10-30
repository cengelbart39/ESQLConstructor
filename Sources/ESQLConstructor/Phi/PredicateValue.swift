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
public enum PredicateValue {
    case string(String)
    case number(Double)
    case date(Date)
    case attribute(String, String)
    
    /// Returns the appropriate `PredicateValue` from a `String`
    public static func make(with str: String) -> PredicateValue {
        if let number = Double(str) {
            return .number(number)
            
        } else if str.contains(".") {
            let split = str.split(separator: ".").map({ String($0) })
            return .attribute(split[0], split[1])
            
        } else if str.contains("'") {
            let cleaned = str.replacingOccurrences(of: "'", with: "")
            return .string(cleaned)
            
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let date = formatter.date(from: str)!
            return .date(date)
        }
    }
    
    var syntax: any ExprSyntaxProtocol {
        switch self {
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
}