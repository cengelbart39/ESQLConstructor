//
//  Predicate.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/30/24.
//  CWID: 10467610
//

import Foundation

/// A structure that rperesents a Grouping Variable or Having Predicate
public struct Predicate: CustomDebugStringConvertible {
    public let value1: PredicateValue
    public let `operator`: Operator
    public let value2: PredicateValue
    
    /// Initializer taking in each value
    public init(value1: PredicateValue, op: Operator, value2: PredicateValue) {
        self.value1 = value1
        self.operator = op
        self.value2 = value2
    }
    
    public var debugDescription: String {
        return "\(value1.debugDescription) \(`operator`.rawValue) \(value2.debugDescription)"
    }
    
    /// Optional initializer taking in an array of 3 `String`s
    /// - Note: If `arr.length != 3`, will always fail
    public init?(arr: [String]) {
        guard arr.count == 3 else {
            return nil
        }
        
        self.value1 = PredicateValue.make(with: arr[0])!
        self.operator = Operator.make(rawValue: arr[1])!
        self.value2 = PredicateValue.make(with: arr[2])!
    }
    
    /// Determines if an attribute exists within a `Predicate`
    /// - Parameter groupingVar: The grouping variable to match
    /// - Returns: Whether it exists on either side of the predicate
    public func hasAttribute(on groupingVar: String) -> Bool {
        switch (value1, value2) {
        case (.attribute(let leftSide, _), _), (_, .attribute(let leftSide, _)):
            return groupingVar == leftSide
        default:
            return false
        }
    }
}

extension Array where Element == Predicate {
    /// Searches an array of `Predicate`s to find attribures for a specified grouping variable
    /// - Parameter groupingVar: The grouping variable to match
    /// - Returns: The matching predicates
    func find(for groupingVar: String) -> [Predicate] {
        return self.filter { $0.hasAttribute(on: groupingVar) }
    }
}
