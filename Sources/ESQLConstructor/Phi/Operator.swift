//
//  Operator.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/30/24.
//

import Foundation

/// The operators used in ``Predicate``
public enum Operator: String {
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
