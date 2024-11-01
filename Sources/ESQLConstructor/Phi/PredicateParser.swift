//
//  PredicateParser.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/31/24.
//

import Foundation

public struct PredicateParser {
    
    public let tokens: [String]
    
    public init(tokens: [String]) {
        self.tokens = tokens
    }
    
    public init(string: String) {
        self.tokens = string
            .split(separator: " ")
            .map({ String($0) })
    }
    
    public func parse() -> Predicate {
        let expression = self.parseAndExpression(tokens: self.tokens)
        let predicate = expression.predicate!
        return predicate
    }
    
    private func parseValue(token: String) -> PredicateValue {
        let value = PredicateValue.make(with: token)
        return value!
    }
        
    private func parseNumericExpression(tokens: [String]) -> PredicateValue {
        let numericIndicies = tokens.indices(where: { NumericOperator(rawValue: $0) != nil }).ranges
    
        guard !numericIndicies.isEmpty else {
            return self.parseValue(token: tokens[0])
        }
        
        let numericToken = NumericOperator(rawValue: tokens[numericIndicies[0].lowerBound])!
        let leftSide = Array(tokens[..<numericIndicies[0].lowerBound])
        let rightSide = Array(tokens[numericIndicies[0].upperBound...])
        
        let leftValue = self.parseValue(token: leftSide[0])
        let rightValue = self.parseValue(token: rightSide[0])
        
        let predicate = Predicate(value1: leftValue, op: .numeric(numericToken), value2: rightValue)
        return .expression(predicate)
    }
    
    private func parseComparisonExpression(tokens: [String]) -> PredicateValue {
        let comparisonIndices = tokens.indices(where: { ComparisonOperator(rawValue: $0) != nil }).ranges
        
        guard !comparisonIndices.isEmpty else {
            return self.parseNumericExpression(tokens: tokens)
        }
        
        let comparisonToken = ComparisonOperator(rawValue: tokens[comparisonIndices[0].lowerBound])!
        let leftSide = Array(tokens[..<comparisonIndices[0].lowerBound])
        let rightSide = Array(tokens[comparisonIndices[0].upperBound...])
        
        let leftValue = self.parseNumericExpression(tokens: leftSide)
        let rightValue = self.parseNumericExpression(tokens: rightSide)
        
        let predicate =  Predicate(value1: leftValue, op: .comparison(comparisonToken), value2: rightValue)
        return .expression(predicate)
    }
    
    private func parseOrExpression(tokens: [String]) -> PredicateValue {
        let orIndices = tokens.indices(where: { LogicalOperator(rawValue: $0) == .or }).ranges
        
        guard !orIndices.isEmpty else {
            return self.parseComparisonExpression(tokens: tokens)
        }
        
        let leftSide = Array(tokens[..<orIndices[0].lowerBound])
        let rightSide = Array(tokens[orIndices[0].upperBound...])
        
        let leftValue = self.parseComparisonExpression(tokens: leftSide)
        let rightValue = self.parseComparisonExpression(tokens: rightSide)
        
        let predicate = Predicate(value1: leftValue, op: .logical(.or), value2: rightValue)
        return .expression(predicate)
    }
    
    
    private func parseAndExpression(tokens: [String]) -> PredicateValue {
        let andIndices = tokens.indices(where: { LogicalOperator(rawValue: $0) == .and }).ranges
        
        guard !andIndices.isEmpty else {
            return self.parseOrExpression(tokens: tokens)
        }
        
        let leftSide = Array(tokens[..<andIndices[0].lowerBound])
        let rightSide = Array(tokens[andIndices[0].upperBound...])
        
        let leftValue = self.parseOrExpression(tokens: leftSide)
        let rightValue = self.parseOrExpression(tokens: rightSide)
        
        let predicate = Predicate(value1: leftValue, op: .logical(.and), value2: rightValue)
        return .expression(predicate)
    }
}
