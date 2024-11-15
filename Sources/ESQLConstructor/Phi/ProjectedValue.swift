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
    case aggregate(any AggregateRepresentable)
    
    var name: String {
        switch self {
        case .attribute(let string):
            return string
        case .aggregate(let aggregateRepresentable):
            return aggregateRepresentable.name
        }
    }
    
    var type: SalesDataType {
        switch self {
        case .attribute(let string):
            return SalesColumn(rawValue: string)!.type
        case .aggregate(let aggregateRepresentable):
            return aggregateRepresentable.type
        }
    }
}
