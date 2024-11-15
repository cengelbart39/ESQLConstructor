//
//  EB+SalesTypealias.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/4/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public extension EvaluatorBuilder {
    struct SalesTypealiasBuilder {
        /// Builds syntax for the `Sales` typealias tuple
        ///
        /// Builds the following syntax:
        /// ```swift
        /// typealias Sales = (String, String, Int, Int, Int, String, Int, Date)
        /// ```
        func buildSyntax() -> TypeAliasDeclSyntax {
            return TypeAliasDeclSyntax(
                name: .identifier("Sales"),
                initializer: TypeInitializerClauseSyntax(
                    value: TupleTypeSyntax(
                        elements: TupleTypeElementListSyntax {
                            // cust
                            self.buildTupleElementSyntax(type: "String", trailingToken: .commaToken())
                            // prod
                            self.buildTupleElementSyntax(type: "String", trailingToken: .commaToken())
                            // day
                            self.buildTupleElementSyntax(type: "Int", trailingToken: .commaToken())
                            // month
                            self.buildTupleElementSyntax(type: "Int", trailingToken: .commaToken())
                            // year
                            self.buildTupleElementSyntax(type: "Int", trailingToken: .commaToken())
                            // state
                            self.buildTupleElementSyntax(type: "String", trailingToken: .commaToken())
                            // quant
                            self.buildTupleElementSyntax(type: "Int", trailingToken: .commaToken())
                            // date
                            self.buildTupleElementSyntax(type: "Date")
                        }
                    )
                ),
                trailingTrivia: .newlines(2)
            )
        }
        
        /// Builds a single `TupleTypeElementSyntax`
        /// - Parameters:
        ///   - type: The type of the tuple element as a `String`
        ///   - trailingToken: Any trailing trivia
        private func buildTupleElementSyntax(type: String, trailingToken: TokenSyntax? = nil) -> TupleTypeElementSyntax {
            return TupleTypeElementSyntax(
                type: IdentifierTypeSyntax(
                    name: .identifier(type)
                ),
                trailingComma: trailingToken
            )
        }
    }
}
