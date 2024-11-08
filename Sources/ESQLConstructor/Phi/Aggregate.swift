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
}

public extension Array where Element == Aggregate {
    /// Determines if an array contains at least 1 average aggregate
    /// - Returns: Whether an array contains at least 1 average aggregate
    func hasAverage() -> Bool {
        return self.reduce(false) { $0 || $1.function == .avg }
    }
}
