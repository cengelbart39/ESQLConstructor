//
//  AttributeAggregate.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/13/24.
//

import Foundation

public struct AttributeAggregate: AggregateRepresentable {
    public let function: AggregateFunction
    public let attribute: String
    
    /// The property name used in `MFStruct` construction
    public var name: String {
        return "\(function.rawValue)_\(attribute)"
    }
}
