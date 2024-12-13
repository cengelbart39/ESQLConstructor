//
//  Phi.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/24/24.
//  CWID: 10467610
//

import Foundation
import OrderedCollections
import SwiftSyntax

/// A structure that represents the Phi Operator's Parameters
public struct Phi {
    public let projectedValues: [ProjectedValue]
    public let numOfGroupingVars: Int
    public let groupByAttributes: [String]
    public let aggregates: [any AggregateRepresentable]
    public let groupingVarPredicates: [Predicate]
    public let havingPredicate: PredicateValue?
    
    /// Creates an instance of `Phi` using a `String`
    /// - Parameter string: A string containing Phi's parameters, each seperated by a `\n`
    /// - Throws: Can throw ``PhiError`` due to bad input
    public init(string: String) throws {
        let split = string.split(separator: "\n").map({ String($0) })
        
        guard split.count >= 5 else {
            throw PhiError.invalidFileLength
        }
        
        let pvString = split[0]
        let pvSplit = pvString.split(separator: ",").map({ String($0).trimmingCharacters(in: .whitespaces) })
        
        var projValues = [ProjectedValue]()
        var groupByAttributes = [String]()
        
        var attrAggregates = OrderedSet<AttributeAggregate>()
        var groupAggregates = OrderedSet<GroupingAggregate>()
        
        for split in pvSplit {
            if !split.contains("_") {
                projValues.append(.attribute(split))
                groupByAttributes.append(split)
                
            } else {
                let underscoreSplit = split.split(separator: "_").map({ String($0) })
                
                if underscoreSplit.count == 2 {
                    let aggregate = AttributeAggregate(
                        function: AggregateFunction(rawValue: underscoreSplit[0])!,
                        attribute: underscoreSplit[1]
                    )
                    projValues.append(.aggregate(aggregate))
                    attrAggregates.append(aggregate)
                    
                } else {
                    let aggregate = GroupingAggregate(
                        function: AggregateFunction(rawValue: underscoreSplit[0])!,
                        groupingVarId: underscoreSplit[1],
                        attribute: underscoreSplit[2]
                    )
                    projValues.append(.aggregate(aggregate))
                    groupAggregates.append(aggregate)
                }
            }
        }
        
        self.projectedValues = projValues
        
        self.numOfGroupingVars = groupAggregates.count
        
        self.groupByAttributes = groupByAttributes
                
        let predicateSplit = split[4].split(separator: ";").map({ String($0) })
        var predicates = [Predicate]()
        
        for predicate in predicateSplit {
            let parser = try PredicateParser(string: predicate)
            let output = try parser.parse()
            
            predicates.append(output.predicate!)
        }
        
        self.groupingVarPredicates = predicates
        
        if (split.count != 6) {
            self.aggregates = Array(attrAggregates) + Array(groupAggregates)
            self.havingPredicate = nil
            
        } else {
            let parser = try PredicateParser(string: split[5])
            let output = try parser.parse()
            
            let havingAggregates = output.aggregates
            havingAggregates.forEach({
                if let groupAgg = $0 as? GroupingAggregate {
                    groupAggregates.append(groupAgg)
                    
                } else if let attrAgg = $0 as? AttributeAggregate {
                    attrAggregates.append(attrAgg)
                }
            })
            
            self.aggregates = Array(attrAggregates) + Array(groupAggregates)
            self.havingPredicate = output
        }
    }

    public enum PhiError: Error {
        case invalidFileLength
        case noProjectedValues
        case badPredicate(String)
    }
}
