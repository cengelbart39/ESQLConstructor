//
//  ProjectedValue.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/30/24.
//

import Foundation

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
