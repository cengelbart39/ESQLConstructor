//
//  Predicate.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/30/24.
//

import Foundation

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
        
        self.value1 = PredicateValue.make(with: arr[0])!
        self.operator = Operator.make(rawValue: arr[1])!
        self.value2 = PredicateValue.make(with: arr[2])!
    }
    
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
    func find(for groupingVar: String) -> [Predicate] {
        return self.filter { $0.hasAttribute(on: groupingVar) }
    }
}
