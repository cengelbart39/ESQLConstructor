//
//  PredicateParser.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/31/24.
//  CWID: 10467610
//

import Foundation

/// A structure that parses a string into a predicate
public struct PredicateParser {
    
    public let tokens: [String]
    
    /// Initialize with a `String`
    /// - Parameter string: A string containg a predicate
    public init(string: String) throws {
        let regex = try NSRegularExpression(pattern: "[0-9]\\.\\w+|\\'\\w+\\'|\\w+|\\(\\)|==|!=|<=|>=|\\=|\\<|\\>|\\+|\\-|[[:punct:]]")
        let results = regex
            .matches(in: string, range: NSRange(location: 0, length: string.count))
            .map({ String(string[Range($0.range, in: string)!]) })
        
        if results.isEmpty {
            throw ParserError.noTokens
        }
        
        self.tokens = results
    }
    
    /// Parses ``tokens`` contained in the structure
    /// - Returns: The top-level `PredicateValue` as an ``PredicateValue/predicate(_:)`` or ``PredicateValue/expression(_:)``
    public func parse() throws -> PredicateValue {
        let expression = try self.parseParenthesesExpression(tokens: self.tokens, parseFunction: self.parseAndExpression)
        return expression
    }
    
    /// Parses a single token into a non-expression ``PredicateValue``
    /// - Parameter tokens: A single token that is not an ``PredicateValue/predicate(_:)``
    /// - Returns: A non-``PredicateValue/predicate(_:)``
    private func parseValue(tokens: [String]) throws -> PredicateValue {
        guard let value = PredicateValue.make(with: tokens[0]) else {
            throw ParserError.invalidToken(tokens[0])
        }
        
        return value
    }
        
    /// Parses expressions with a ``NumericOperator``
    /// - Parameter tokens: A list of tokens
    /// - Returns: The associated ``PredicateValue`` of the whole expression. The top-level expression has an ``NumericOperator``
    /// - Note: Fallbacks to ``parseValue`` in absence of a numeric token
    private func parseNumericExpression(tokens: [String]) throws -> PredicateValue {
        if self.isParenthesesExpression(tokens: tokens) {
            return try self.parseParenthesesExpression(
                tokens: tokens,
                parseFunction: self.parseNumericExpression
            )
        }
        
        if self.isNotExpression(tokens: tokens) {
            return try self.parseNotExpression(tokens: Array(tokens[1...]), parseInnerExpression: self.parseNumericExpression)
        }
        
        let numericIndex = tokens.firstIndex(where: { NumericOperator(rawValue: $0) != nil })
    
        guard let numericIndex = numericIndex else {
            return try self.parseValue(tokens: tokens)
        }
        
        let numericToken = NumericOperator(rawValue: tokens[numericIndex])!
        let leftSide = Array(tokens[..<numericIndex])
        let rightSide = Array(tokens[(numericIndex + 1)...])
        
        let leftValue = try self.parseValue(tokens: leftSide)
        let rightValue = try self.parseValue(tokens: rightSide)
        
        let predicate = Predicate(value1: leftValue, op: .numeric(numericToken), value2: rightValue)
        return .predicate(predicate)
    }
    
    /// Parses expressions with a ``ComparisonOperator``
    /// - Parameter tokens: A list of tokens
    /// - Returns: The associated ``PredicateValue`` of the whole expression. The top-level expression has an ``ComparisonOperator``
    /// - Note: Fallbacks to ``parseNumericExpression`` in absence of a comparison token
    private func parseComparisonExpression(tokens: [String]) throws -> PredicateValue {
        if self.isParenthesesExpression(tokens: tokens) {
            return try self.parseParenthesesExpression(
                tokens: tokens,
                parseFunction: self.parseComparisonExpression
            )
        }
        
        if self.isNotExpression(tokens: tokens) {
            return try self.parseNotExpression(tokens: Array(tokens[1...]), parseInnerExpression: self.parseComparisonExpression)
        }
        
        let comparisonIndex = tokens.firstIndex(where: { ComparisonOperator(rawValue: $0) != nil })
        
        guard let comparisonIndex = comparisonIndex else {
            return try self.parseParenthesesExpression(tokens: tokens, parseFunction: self.parseNumericExpression)
        }
        
        let comparisonToken = ComparisonOperator(rawValue: tokens[comparisonIndex])!
        let leftSide = Array(tokens[..<comparisonIndex])
        let rightSide = Array(tokens[(comparisonIndex + 1)...])
        
        let leftValue = try parseParenthesesExpression(tokens: leftSide, parseFunction: self.parseNumericExpression)
        let rightValue = try parseParenthesesExpression(tokens: rightSide, parseFunction: self.parseNumericExpression)
        
        let predicate =  Predicate(value1: leftValue, op: .comparison(comparisonToken), value2: rightValue)
        return .predicate(predicate)
    }
    
    /// Parses expressions with `or` token(s)
    /// - Parameter tokens: A list of tokens
    /// - Returns: The associated ``PredicateValue`` of the whole expression. The top-level expression has an ``LogicalOperator/or`` operator
    /// - Note: Fallbacks to ``parseComparisonExpression`` in absence of `or` token
    private func parseOrExpression(tokens: [String]) throws -> PredicateValue {
        if self.isParenthesesExpression(tokens: tokens) {
            return try self.parseParenthesesExpression(
                tokens: tokens,
                parseFunction: self.parseOrExpression
            )
        }
        
        if self.isNotExpression(tokens: tokens) {
            return try self.parseNotExpression(tokens: Array(tokens[1...]), parseInnerExpression: self.parseOrExpression)
        }
        
        let orIndices = tokens.indices(where: { LogicalOperator(rawValue: $0) == .or }).ranges
        
        guard !orIndices.isEmpty else {
            return try self.parseParenthesesExpression(tokens: tokens, parseFunction: self.parseComparisonExpression)
        }
        
        let leftSide = Array(tokens[..<orIndices[0].lowerBound])
        let rightSide = Array(tokens[orIndices[0].upperBound...])
        
        if orIndices.count == 1 {
            let leftValue = try self.parseParenthesesExpression(tokens: leftSide, parseFunction: self.parseComparisonExpression)
            let rightValue = try self.parseParenthesesExpression(tokens: rightSide, parseFunction: self.parseComparisonExpression)
            
            let predicate = Predicate(value1: leftValue, op: .logical(.or), value2: rightValue)
            return .predicate(predicate)
            
        } else {
            let leftValue = try parseParenthesesExpression(tokens: leftSide, parseFunction: self.parseComparisonExpression)
            let rightValue = try parseParenthesesExpression(tokens: rightSide, parseFunction: self.parseOrExpression)
            
            let predicate = Predicate(value1: leftValue, op: .logical(.or), value2: rightValue)
            return .predicate(predicate)
        }
    }
    
    
    /// Parses expressions with `and` token(s)
    /// - Parameter tokens: A list of tokens
    /// - Returns: The associated ``PredicateValue`` of the whole expression. The top-level expression has an ``LogicalOperator/and`` operator
    /// - Note: Fallbacks to ``parseOrExpression`` in absence of `and` token
    private func parseAndExpression(tokens: [String]) throws -> PredicateValue {
        if self.isParenthesesExpression(tokens: tokens) {
            return try self.parseParenthesesExpression(
                tokens: tokens,
                parseFunction: self.parseAndExpression
            )
        }
        
        if self.isNotExpression(tokens: tokens) {
            return try self.parseNotExpression(tokens: Array(tokens[1...]), parseInnerExpression: self.parseAndExpression)
        }
        
        let andIndices = tokens.indices(where: { LogicalOperator(rawValue: $0) == .and }).ranges
        
        guard !andIndices.isEmpty else {
            return try parseParenthesesExpression(tokens: tokens, parseFunction: self.parseOrExpression)
        }
        
        let leftSide = Array(tokens[..<andIndices[0].lowerBound])
        let rightSide = Array(tokens[andIndices[0].upperBound...])
        
        if andIndices.count == 1 {
            let leftValue = try parseParenthesesExpression(tokens: leftSide, parseFunction: self.parseOrExpression)
            let rightValue = try parseParenthesesExpression(tokens: rightSide, parseFunction: self.parseOrExpression)
            
            let predicate = Predicate(value1: leftValue, op: .logical(.and), value2: rightValue)
            return .predicate(predicate)
            
        } else {
            let leftValue = try parseParenthesesExpression(tokens: leftSide, parseFunction: self.parseOrExpression)
            let rightValue = try parseParenthesesExpression(tokens: rightSide, parseFunction: self.parseAndExpression)
            
            let predicate = Predicate(value1: leftValue, op: .logical(.and), value2: rightValue)
            return .predicate(predicate)
        }
    }
    
    /// A helper function to determine if the leading token is the `not` operator
    /// - Parameter tokens: An array of `String` tokens
    /// - Returns: Whether the leading token is the `not` operator
    /// - SeeAlso: ``parseNotTokens(tokens:parseInnerExpression:)``
    private func isNotExpression(tokens: [String]) -> Bool {
        if tokens.isEmpty {
            return false
        }
        
        return LogicalOperator(rawValue: tokens[0]) == .not
    }
    
    /// Parses an expression with a leading `not` token
    /// - Parameters:
    ///   - tokens: An array of `String` tokens
    ///   - parseInnerExpression: A function that processes the inner expression of the `not` operator (e.g. what `not` is applied to)
    /// - Returns: The associated ``PredicateValue`` of the whole expression
    /// - SeeAlso: ``isNotExpression()``
    ///
    /// Unlike the other parser functions, this one returns a predicate like this:
    /// ```swift
    /// Predicate(value1: innerValue, op: .comparison(.equal), value2: .boolean(false))
    /// ```
    /// This expression is logically equivalent to `!(innerValue)`. This format is used to prevent a rewrite of ``Predicate`` or the creation of whole new structure
    private func parseNotExpression(
        tokens: [String],
        parseInnerExpression: ([String]) throws -> PredicateValue
    ) throws -> PredicateValue {
        let innerExpression = Array(tokens[1...])
        let innerValue = try self.parseParenthesesExpression(tokens: innerExpression, parseFunction: parseInnerExpression)
        
        let predicate =  Predicate(value1: innerValue, op: .comparison(.equal), value2: .boolean(false))
        return .predicate(predicate)
    }
    
    /// Whether an set of tokens is wrapped in parentheses
    /// - Parameter tokens: An array of `String` tokens
    /// - Returns: Whether an expression is wrapped in parentheses
    /// - Note: If `tokens` is empty, always returns `false`
    private func isParenthesesExpression(tokens: [String]) -> Bool {
        if tokens.isEmpty {
            return false
        }
        
        return tokens.first == "(" && tokens.last == ")"
    }
    
    /// Parses an expression wrapped in parantheses.
    /// - Parameters:
    ///   - tokens: An array of `String` tokens
    ///   - parseFunction: A function to process the inner expression of the parantheses or when there are no parentheses
    /// - Returns: A ``PredicateValue/expression(_:)`` for the `tokens`
    private func parseParenthesesExpression(
        tokens: [String],
        parseFunction: ([String]) throws -> PredicateValue
    ) throws -> PredicateValue {
        if tokens.isEmpty {
            throw ParserError.noTokens
        }
        
        if isNotExpression(tokens: tokens) {
            return try parseNotExpression(tokens: tokens, parseInnerExpression: parseFunction)
        }
        
        if tokens.first != "(" {
            return try parseFunction(tokens)
        }
        
        let outerPair = findParantheseRange(tokens: tokens)
        
        guard outerPair.end != -1 else {
            throw ParserError.missingClosingParenthesis
        }
        
        let innerExpression = Array(tokens[(outerPair.start+1)..<outerPair.end])
        let innerValue = try parseFunction(innerExpression).predicate!
        
        let result = try self.parseParenthesesRemainder(
            tokens: tokens,
            innerValue: innerValue,
            outerPair: outerPair,
            parseFunction: parseFunction
        )
        
        return result
    }
    
    /// Finds the range between an outer pair of parantheses
    /// - Parameter tokens: An array of `String` tokens
    /// - Precondition: The first token of `tokens` is a `"("`
    /// - Returns: A tuple containing the start and end index of a paranthese pair in `tokens`
    /// - Note: If there are missing closing parantheses, `end` will equal `-1`
    private func findParantheseRange(tokens: [String]) -> (start: Int, end: Int) {
        let enumerated = tokens.enumerated().filter({ $0.element == "(" || $0.element == ")" })
        
        var outerPair  = (start: 0, end: -1)
        var depth = 0
        
        for (index, token) in enumerated {
            if token == "(" {
                depth += 1
                
            } else {
                depth -= 1
                if depth == 0 {
                    outerPair = (start: 0, end: index)
                    break
                }
            }
        }
        
        return outerPair
    }
    
    /// Handles the parsing of the operator and right-hand side, after the parsing of a parenthese expression
    /// - Parameters:
    ///   - tokens: The full token array, including the left-hand side processed by the caller
    ///   - innerValue: The value of the left-hand side as calculated by the caller
    ///   - outerPair: The index of `tokens` at which the last closing parenthesis of the left-hand side is located
    ///   - parseFunction: A function that parses the remaining expression
    /// - Returns: A `PredicateValue` for `tokens`
    /// - Warning: Assuming a token scheme of `(lhs) <op> rhs`, if the first token of the right-hand side is ``LogicalOperator/not``, this function throws an error.
    /// - Note: In practice, this function is used after ``parseParenthesesExpression(tokens:parseFunction:)``. As such,
    /// if the operator in the remainder tokens is ``LogicalOperator/not``, a `fatalError()` is thrown, as it should never reach here.
    private func parseParenthesesRemainder(
        tokens: [String],
        innerValue: Predicate,
        outerPair: (start: Int, end: Int),
        parseFunction: ([String]) throws -> PredicateValue
    ) throws -> PredicateValue {
        // If the outer pair indicates the the parenthese grouping
        // ends at the last element of the tokens array
        // there is nothing more to do
        if outerPair.end == tokens.count - 1 {
            return .expression(innerValue)
            
        // Otherwise, there is some remaining expression to handle
        } else {
            // First we need to isolate the operator from the rhs
            let remainderArray = Array(tokens[(outerPair.end+1)...])
            let op = Operator.make(rawValue: remainderArray.first!)!
            let remainder = Array(remainderArray.dropFirst())
            
            // Now we need to call the appropriate function based
            // on the operator
            switch op {
            case .logical(.and):
                let remainderValue = try parseParenthesesExpression(tokens: remainder, parseFunction: self.parseOrExpression)
                let predicate = Predicate(value1: .expression(innerValue), op: op, value2: remainderValue)
                return .expression(predicate)
                
            case .logical(.or):
                let remainderValue = try parseParenthesesExpression(tokens: remainder, parseFunction: self.parseComparisonExpression)
                let predicate = Predicate(value1: .expression(innerValue), op: op, value2: remainderValue)
                return .expression(predicate)
                
            // Should never reach here as not is handeled earlier
            case .logical(.not):
                throw ParserError.rightHandSideHasNotOperator
                
            case .comparison(_):
                let remainderValue = try parseParenthesesExpression(tokens: remainder, parseFunction: self.parseNumericExpression)
                let predicate = Predicate(value1: .expression(innerValue), op: op, value2: remainderValue)
                return .expression(predicate)
                
            case .numeric(_):
                let remainderValue = try parseParenthesesExpression(tokens: remainder, parseFunction: self.parseValue)
                let predicate = Predicate(value1: .expression(innerValue), op: op, value2: remainderValue)
                return .expression(predicate)
            }
        }
    }
    
    enum ParserError: Error {
        case noTokens
        case invalidToken(String)
        case rightHandSideHasNotOperator
        case missingOpeningParenthesis
        case missingClosingParenthesis
    }
}
