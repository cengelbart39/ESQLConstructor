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
}
