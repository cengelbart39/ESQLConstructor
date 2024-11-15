//
//  GroupingAggregate.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/30/24.
//

import Foundation
import SwiftSyntax

/// Represents an expression that uses an Aggregate function tied to a grouping variable
public struct GroupingAggregate: AggregateRepresentable {
    public let function: AggregateFunction
    public let groupingVarId: String
    public let attribute: String
    
    /// The property name used in `MFStruct` construction
    public var name: String {
        return "\(function.rawValue)_\(groupingVarId)_\(attribute)"
    }
}

public extension Array where Element == GroupingAggregate {
    /// Creates a 2D array of aggregates, where each inner array belongs to the same grouping variable
    func groupByVariableId() -> [[GroupingAggregate]] {
        let ids = self.map({ $0.groupingVarId })
        
        var dict = [String : [GroupingAggregate]]()
        for index in 0..<ids.count {
            if dict[ids[index]] == nil {
                dict[ids[index]] = [self[index]]
                
            } else {
                dict[ids[index]]!.append(self[index])
            }
        }
        
        let output = dict.keys.sorted().map({ dict[$0]! })
        return output
    }
}
