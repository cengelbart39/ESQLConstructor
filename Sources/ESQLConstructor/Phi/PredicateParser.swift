//
//  PredicateParser.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/31/24.
//

import Foundation

/// A structure that parses a string into a predicate
public struct PredicateParser {
    
    public let tokens: [String]
    
    /// Initialize with an array of `String`
    /// - Parameter tokens: An array of individual tokens
    public init(tokens: [String]) {
        self.tokens = tokens
    }
    
    /// Initialize with a `String`
    /// - Parameter string: A string of whitespace-seperated tokens
    public init(string: String) {
        self.tokens = string
            .split(separator: " ")
            .map({ String($0) })
    }
    
    /// Parses ``tokens`` contained in the structure
    /// - Returns: The top-level predicate
    public func parse() -> Predicate {
        let expression = self.parseAndExpression(tokens: self.tokens)
        let predicate = expression.predicate!
        return predicate
    }
    
    /// Parses a single token into a non-expression ``PredicateValue``
    /// - Parameter token: A single token that is not an ``PredicateValue/expression(_:)``
    /// - Returns: A non-``PredicateValue/expression(_:)``
    private func parseValue(token: String) -> PredicateValue {
        let value = PredicateValue.make(with: token)
        return value!
    }
        
    /// Parses expressions with a ``NumericOperator``
    /// - Parameter tokens: A list of tokens
    /// - Returns: The associated ``PredicateValue`` of the whole expression. The top-level expression has an ``NumericOperator``
    /// - Note: Fallbacks to ``parseValue`` in absence of a numeric token
    private func parseNumericExpression(tokens: [String]) -> PredicateValue {
        let numericIndex = tokens.firstIndex(where: { NumericOperator(rawValue: $0) != nil })
    
        guard let numericIndex = numericIndex else {
            return self.parseValue(token: tokens[0])
        }
        
        let numericToken = NumericOperator(rawValue: tokens[numericIndex])!
        let leftSide = Array(tokens[..<numericIndex])
        let rightSide = Array(tokens[(numericIndex + 1)...])
        
        let leftValue = self.parseValue(token: leftSide[0])
        let rightValue = self.parseValue(token: rightSide[0])
        
        let predicate = Predicate(value1: leftValue, op: .numeric(numericToken), value2: rightValue)
        return .expression(predicate)
    }
    
    /// Parses expressions with a ``ComparisonOperator``
    /// - Parameter tokens: A list of tokens
    /// - Returns: The associated ``PredicateValue`` of the whole expression. The top-level expression has an ``ComparisonOperator``
    /// - Note: Fallbacks to ``parseNumericExpression`` in absence of a comparison token
    private func parseComparisonExpression(tokens: [String]) -> PredicateValue {
        let comparisonIndex = tokens.firstIndex(where: { ComparisonOperator(rawValue: $0) != nil })
        
        guard let comparisonIndex = comparisonIndex else {
            return self.parseNumericExpression(tokens: tokens)
        }
        
        let comparisonToken = ComparisonOperator(rawValue: tokens[comparisonIndex])!
        let leftSide = Array(tokens[..<comparisonIndex])
        let rightSide = Array(tokens[(comparisonIndex + 1)...])
        
        let leftValue = self.parseNumericExpression(tokens: leftSide)
        let rightValue = self.parseNumericExpression(tokens: rightSide)
        
        let predicate =  Predicate(value1: leftValue, op: .comparison(comparisonToken), value2: rightValue)
        return .expression(predicate)
    }
    
    /// Parses expressions with `or` token(s)
    /// - Parameter tokens: A list of tokens
    /// - Returns: The associated ``PredicateValue`` of the whole expression. The top-level expression has an ``LogicalOperator/or`` operator
    /// - Note: Fallbacks to ``parseComparisonExpression`` in absence of `or` token
    private func parseOrExpression(tokens: [String]) -> PredicateValue {
        let orIndices = tokens.indices(where: { LogicalOperator(rawValue: $0) == .or }).ranges
        
        guard !orIndices.isEmpty else {
            return self.parseComparisonExpression(tokens: tokens)
        }
        
        let leftSide = Array(tokens[..<orIndices[0].lowerBound])
        let rightSide = Array(tokens[orIndices[0].upperBound...])
        
        if orIndices.count == 1 {
            let leftValue = self.parseComparisonExpression(tokens: leftSide)
            let rightValue = self.parseComparisonExpression(tokens: rightSide)
            
            let predicate = Predicate(value1: leftValue, op: .logical(.or), value2: rightValue)
            return .expression(predicate)
            
        } else {
            let leftValue = self.parseComparisonExpression(tokens: leftSide)
            let rightValue = self.parseOrExpression(tokens: rightSide)
            
            let predicate = Predicate(value1: leftValue, op: .logical(.or), value2: rightValue)
            return .expression(predicate)
        }
    }
    
    
    /// Parses expressions with `and` token(s)
    /// - Parameter tokens: A list of tokens
    /// - Returns: The associated ``PredicateValue`` of the whole expression. The top-level expression has an ``LogicalOperator/and`` operator
    /// - Note: Fallbacks to ``parseOrExpression`` in absence of `and` token
    private func parseAndExpression(tokens: [String]) -> PredicateValue {
        let andIndices = tokens.indices(where: { LogicalOperator(rawValue: $0) == .and }).ranges
        
        guard !andIndices.isEmpty else {
            return self.parseOrExpression(tokens: tokens)
        }
        
        let leftSide = Array(tokens[..<andIndices[0].lowerBound])
        let rightSide = Array(tokens[andIndices[0].upperBound...])
        
        if andIndices.count == 1 {
            let leftValue = self.parseOrExpression(tokens: leftSide)
            let rightValue = self.parseOrExpression(tokens: rightSide)
            
            let predicate = Predicate(value1: leftValue, op: .logical(.and), value2: rightValue)
            return .expression(predicate)
            
        } else {
            let leftValue = self.parseOrExpression(tokens: leftSide)
            let rightValue = self.parseAndExpression(tokens: rightSide)
            
            let predicate = Predicate(value1: leftValue, op: .logical(.and), value2: rightValue)
            return .expression(predicate)
        }
    }
}
