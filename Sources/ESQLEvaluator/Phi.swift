//
//  Phi.swift
//  ESQLEvaluator
//
//  Created by Christopher Engelbart on 10/24/24.
//

import Foundation

/// A structure that represents the Phi Operator's Parameters
struct Phi {
    let projectedValues: [ProjectedValue]
    let numOfGroupingVars: Int
    let groupByAttributes: [String]
    let aggregates: [Aggregate]
    let groupingVarPredicates: [Predicate]
    let havingPredicates: [Predicate]
    
    /// Creates an instance of `Phi` using a `String`
    /// - Parameter string: A string containing Phi's parameters, each seperated by a `\n`
    /// - Throws: Can throw ``PhiError`` due to bad input
    init(string: String) throws {
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
    
    enum PhiError: Error {
        case invalidFileLength
        case noProjectedValues
        case badPredicate(String)
    }
}

/// An enum for different types of projected values in ``Phi``
enum ProjectedValue {
    case attribute(String)
    case aggregate(Aggregate)
    
    /// The property name used in `MFStruct` construction
    var name: String {
        switch self {
        case .attribute(let string):
            return string
        case .aggregate(let aggregate):
            return aggregate.name
        }
    }
    
    /// The type of the proprety used in `MFStruct` construction
    var type: String {
        switch self {
        case .attribute(let string):
            return SalesSchema(rawValue: string)!.type
        case .aggregate(let aggregate):
            return SalesSchema(rawValue: aggregate.attribute)!.type
        }
    }
}

/// Represents all possible aggregate functions
enum AggregateFunction: String {
    case max = "max"
    case min = "min"
    case count = "count"
    case sum = "sum"
    case avg = "avg"
}

/// Represents an expression that uses an Aggregate function
struct Aggregate {
    let function: AggregateFunction
    let groupingVarId: String
    let attribute: String
    
    /// The property name used in `MFStruct` construction
    var name: String {
        return "\(function.rawValue)_\(groupingVarId)_\(attribute)"
    }
}

/// A structure that rperesents a Grouping Variable or Having Predicate
struct Predicate {
    let value1: PredicateValue
    let `operator`: Operator
    let value2: PredicateValue
    
    init(value1: PredicateValue, op: Operator, value2: PredicateValue) {
        self.value1 = value1
        self.operator = op
        self.value2 = value2
    }
    
    init?(arr: [String]) {
        guard arr.count == 3 else {
            return nil
        }
        
        self.value1 = PredicateValue.make(with: arr[0])
        self.operator = Operator(rawValue: arr[1])!
        self.value2 = PredicateValue.make(with: arr[2])
    }
}

/// The type of values that can appear in predicates, aside from operators
enum PredicateValue {
    case string(String)
    case number(Double)
    case date(Date)
    case attribute(String, String)
    
    /// Returns the appropriate `PredicateValue` from a `String`
    static func make(with str: String) -> PredicateValue {
        if let number = Double(str) {
            return .number(number)
            
        } else if str.contains(".") {
            let split = str.split(separator: ".").map({ String($0) })
            return .attribute(split[0], split[1])
            
        } else if str.contains("'") {
            let cleaned = str.replacingOccurrences(of: "'", with: "")
            return .string(cleaned)
            
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let date = formatter.date(from: str)!
            return .date(date)
        }
    }
}

/// The operators used in ``Predicate``
enum Operator: String {
    case equal = "="
    case notEqual = "!="
}
