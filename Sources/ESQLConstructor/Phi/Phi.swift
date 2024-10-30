//
//  Phi.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/24/24.
//

import Foundation
import SwiftSyntax

/// A structure that represents the Phi Operator's Parameters
public struct Phi {
    public let projectedValues: [ProjectedValue]
    public let numOfGroupingVars: Int
    public let groupByAttributes: [String]
    public let aggregates: [Aggregate]
    public let groupingVarPredicates: [Predicate]
    public let havingPredicates: [Predicate]
    
    /// Creates an instance of `Phi` using a `String`
    /// - Parameter string: A string containing Phi's parameters, each seperated by a `\n`
    /// - Throws: Can throw ``PhiError`` due to bad input
    public init(string: String) throws {
        let split = string.split(separator: "\n").map({ String($0 )})
        
        guard split.count >= 5 else {
            throw PhiError.invalidFileLength
        }
        
        let pvString = split[0]
        let pvSplit = pvString.split(separator: ",").map({ String($0).trimmingCharacters(in: .whitespaces) })
        
        var projValues = [ProjectedValue]()
        var groupByAttributes = [String]()
        var aggregates = [Aggregate]()
        
        for split in pvSplit {
            if !split.contains("_") {
                projValues.append(.attribute(split))
                groupByAttributes.append(split)
                
            } else {
                let underscoreSplit = split.split(separator: "_").map({ String($0) })
                let aggregate = Aggregate(
                    function: AggregateFunction(rawValue: underscoreSplit[0])!,
                    groupingVarId: underscoreSplit[1],
                    attribute: underscoreSplit[2]
                )
                projValues.append(.aggregate(aggregate))
                aggregates.append(aggregate)
            }
        }
        
        self.projectedValues = projValues
        
        self.numOfGroupingVars = aggregates.count
        
        self.groupByAttributes = groupByAttributes
        
        self.aggregates = aggregates
        
        let predicateSplit = split[4].split(separator: ";").map({ String($0) })
        var predicates = [Predicate]()
        
        for predicate in predicateSplit {
            let components = predicate.split(separator: " ").map({ String($0) })
            
            guard let p = Predicate(arr: components) else {
                throw PhiError.badPredicate(predicate)
            }
            
            predicates.append(p)
        }
        
        self.groupingVarPredicates = predicates
        
        if (split.count != 6) {
            self.havingPredicates = []
            
        } else {
            let hPredicateSplit = split[5].split(separator: ";").map({ String($0) })
            var hPredicates = [Predicate]()
            
            for predicate in hPredicateSplit {
                let components = predicate.split(separator: " ").map({ String($0) })
                
                guard let p = Predicate(arr: components) else {
                    throw PhiError.badPredicate(predicate)
                }
                
                hPredicates.append(p)
            }
            
            self.havingPredicates = hPredicates
        }
    }
    
    public enum PhiError: Error {
        case invalidFileLength
        case noProjectedValues
        case badPredicate(String)
    }
}
