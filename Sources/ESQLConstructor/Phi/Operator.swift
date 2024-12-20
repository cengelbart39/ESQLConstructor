//
//  Operator.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/30/24.
//  CWID: 10467610
//

import Foundation

protocol Operable {
    /// The equivalent operator in `Swift`
    var swiftEquivalent: String { get }
}

/// Operations that can be performed only on numeric values
public enum NumericOperator: String, Operable {
    case add = "+"
    case subtract = "-"
    case multiply = "*"
    case divide = "/"
    case modulo = "%"
    
    var swiftEquivalent: String {
        return self.rawValue
    }
}

/// Operations that compare two values of the same type
public enum ComparisonOperator: String, Operable {
    case equal = "="
    case notEqual = "!="
    case lessThan = "<"
    case lessThanOrEqual = "<="
    case greaterThan = ">"
    case greatherThanOrEqual = ">="
    
    var swiftEquivalent: String {
        switch self {
        case .equal:
            return "=="
        default:
            return self.rawValue
        }
    }
}

/// Operations that pair boolean expressions
public enum LogicalOperator: String, Operable {
    case and = "and"
    case or = "or"
    case not = "not"
    
    /// Attempts to get a case based on a string, case-insenstive
    /// - Parameter rawValue: The equivalent `LogicalOperator`, if there is one
    public init?(rawValue: String) {
        if rawValue.lowercased() == LogicalOperator.and.rawValue {
            self = .and
            
        } else if rawValue.lowercased() == LogicalOperator.or.rawValue {
            self = .or
            
        } else if rawValue.lowercased() == LogicalOperator.not.rawValue {
            self = .not
            
        } else {
            return nil
        }
    }
    
    var swiftEquivalent: String {
        switch self {
        case .and:
            return "&&"
        case .or:
            return "||"
        case .not:
            return "!"
        }
    }
}

/// The operators used in ``Predicate``
public enum Operator: Operable {
    case numeric(NumericOperator)
    case comparison(ComparisonOperator)
    case logical(LogicalOperator)
    
    public var rawValue: String {
        switch self {
        case .numeric(let numericOperator):
            return numericOperator.rawValue
        case .comparison(let comparisonOperator):
            return comparisonOperator.rawValue
        case .logical(let logicalOperator):
            return logicalOperator.rawValue
        }
    }
    
    /// In some cases, the notation between Swift and SQL are different, so this returns the correct Swift symbol
    public var swiftEquivalent: String {
        switch self {
        case .numeric(let numericOperator):
            return numericOperator.swiftEquivalent
        case .comparison(let comparisonOperator):
            return comparisonOperator.swiftEquivalent
        case .logical(let logicalOperator):
            return logicalOperator.swiftEquivalent
        }
    }
    
    /// Generates the appropriate `Operator` for a given string
    /// - Parameter rawValue: The operator as a `String`
    /// - Returns: The appropriate `Operator` for `rawValue`, if there is one
    public static func make(rawValue: String) -> Operator? {
        if let numeric = NumericOperator(rawValue: rawValue) {
            return .numeric(numeric)
            
        } else if let comparison = ComparisonOperator(rawValue: rawValue) {
            return .comparison(comparison)
            
        } else if let logical = LogicalOperator(rawValue: rawValue) {
            return .logical(logical)
            
        } else {
            return nil
        }
    }
}
