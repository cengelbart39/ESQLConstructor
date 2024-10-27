//
//  Phi.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/24/24.
//

import Foundation
import SwiftSyntax

/// A structure that represents the Phi Operator's Parameters
public struct Phi {
    public let projectedValues: [ProjectedValue]
    public let numOfGroupingVars: Int
    public let groupByAttributes: [String]
    public let aggregates: [Aggregate]
    public let groupingVarPredicates: [Predicate]
    public let havingPredicates: [Predicate]
    
    /// Creates an instance of `Phi` using a `String`
    /// - Parameter string: A string containing Phi's parameters, each seperated by a `\n`
    /// - Throws: Can throw ``PhiError`` due to bad input
    public init(string: String) throws {
        let split = string.split(separator: "\n").map({ String($0 )})
        
        guard split.count >= 5 else {
            throw PhiError.invalidFileLength
        }
        
        let pvString = split[0]
        let pvSplit = pvString.split(separator: ",").map({ String($0).trimmingCharacters(in: .whitespaces) })
        
        var projValues = [ProjectedValue]()
        var groupByAttributes = [String]()
        var aggregates = [Aggregate]()
        
        for split in pvSplit {
            if !split.contains("_") {
                projValues.append(.attribute(split))
                groupByAttributes.append(split)
                
            } else {
                let underscoreSplit = split.split(separator: "_").map({ String($0) })
                let aggregate = Aggregate(
                    function: AggregateFunction(rawValue: underscoreSplit[0])!,
                    groupingVarId: underscoreSplit[1],
                    attribute: underscoreSplit[2]
                )
                projValues.append(.aggregate(aggregate))
                aggregates.append(aggregate)
            }
        }
        
        self.projectedValues = projValues
        
        self.numOfGroupingVars = aggregates.count
        
        self.groupByAttributes = groupByAttributes
        
        self.aggregates = aggregates
        
        let predicateSplit = split[4].split(separator: ";").map({ String($0) })
        var predicates = [Predicate]()
        
        for predicate in predicateSplit {
            let components = predicate.split(separator: " ").map({ String($0) })
            
            guard let p = Predicate(arr: components) else {
                throw PhiError.badPredicate(predicate)
            }
            
            predicates.append(p)
        }
        
        self.groupingVarPredicates = predicates
        
        if (split.count != 6) {
            self.havingPredicates = []
            
        } else {
            let hPredicateSplit = split[5].split(separator: ";").map({ String($0) })
            var hPredicates = [Predicate]()
            
            for predicate in hPredicateSplit {
                let components = predicate.split(separator: " ").map({ String($0) })
                
                guard let p = Predicate(arr: components) else {
                    throw PhiError.badPredicate(predicate)
                }
                
                hPredicates.append(p)
            }
            
            self.havingPredicates = hPredicates
        }
    }
    
    public enum PhiError: Error {
        case invalidFileLength
        case noProjectedValues
        case badPredicate(String)
    }
}

/// An enum for different types of projected values in ``Phi``
public enum ProjectedValue {
    case attribute(String)
    case aggregate(Aggregate)
    
    /// The property name used in `MFStruct` construction
    public var name: String {
        switch self {
        case .attribute(let string):
            return string
        case .aggregate(let aggregate):
            return aggregate.name
        }
    }
    
    /// The type of the proprety used in `MFStruct` construction
    public var type: String {
        switch self {
        case .attribute(let string):
            return SalesColumn(rawValue: string)!.type
        case .aggregate(let aggregate):
            return SalesColumn(rawValue: aggregate.attribute)!.type
        }
    }
    
    public var isAttribute: Bool {
        switch self {
        case .attribute(_):
            return true
        case .aggregate(_):
            return false
        }
    }
}

public extension Array where Element == ProjectedValue {
    func attributes() -> [ProjectedValue] {
        return self.filter({ $0.isAttribute })
    }
    
    func aggregates() -> [ProjectedValue] {
        return self.filter({ !$0.isAttribute })
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

/// A structure that rperesents a Grouping Variable or Having Predicate
public struct Predicate {
    public let value1: PredicateValue
    public let `operator`: Operator
    public let value2: PredicateValue
    
    public init(value1: PredicateValue, op: Operator, value2: PredicateValue) {
        self.value1 = value1
        self.operator = op
        self.value2 = value2
    }
    
    public init?(arr: [String]) {
        guard arr.count == 3 else {
            return nil
        }
        
        self.value1 = PredicateValue.make(with: arr[0])
        self.operator = Operator(rawValue: arr[1])!
        self.value2 = PredicateValue.make(with: arr[2])
    }
}

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
}

/// The operators used in ``Predicate``
public enum Operator: String {
    case equal = "="
    case notEqual = "!="
}
