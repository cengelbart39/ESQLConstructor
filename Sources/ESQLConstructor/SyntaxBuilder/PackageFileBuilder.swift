//
//  PackageFileBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/25/24.
//

import Foundation
import SwiftSyntax

struct PackageFileBuilder {
    /// Generate a `Package.swift` file for the resulting code
    /// - Returns: A `CodeBlockItemListSyntax` for a `Package.swift` file
    ///
    /// This produces a syntax equivalent to:
    /// ```swift
    /// // swift-tools-version: 6.0
    ///
    /// import PackageDescription
    ///
    /// let package = Package(
    ///    name: "ESQLEvaluator",
    ///    platforms: [.macOS(.v15)],
    ///    products: [
    ///        .library(
    ///            name: "ESQLEvaluator",
    ///            targets: ["ESQLEvaluator"]
    ///        )
    ///    ],
    ///    dependencies: [
    ///        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.21.0",),
    ///        .package(url: "https://github.com/ph1ps/swift-concurrency-deadline.git", from: "0.1.1",),
    ///        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0")
    ///    ],
    ///    targets: [
    ///        .executableTarget(
    ///            name: "ESQLEvaluator",
    ///            dependencies: [
    ///                .product(name: "ArgumentParser", package: "swift-argument-parser"),
    ///                .product(name: "PostgresNIO", package: "postgres-nio"),
    ///                .product(name: "Deadline", package: "swift-concurrency-deadline")
    ///            ]
    ///        )
    ///    ]
    ///)
    /// ```
    private func buildSyntax() -> CodeBlockItemListSyntax {
        return CodeBlockItemListSyntax {
            CodeBlockItemSyntax(
                leadingTrivia: .lineComment("// swift-tools-version: 6.0\n\n"),
                item: CodeBlockItemSyntax.Item(
                    ImportDeclSyntax(
                        path: ImportPathComponentListSyntax {
                            ImportPathComponentSyntax(name: .identifier("PackageDescription"))
                        }
                    )
                ),
                trailingTrivia: .newline
            )
            
            CodeBlockItemSyntax(
                item: CodeBlockItemSyntax.Item(
                    VariableDeclSyntax(
                        leadingTrivia: .newline,
                        bindingSpecifier: .keyword(.let),
                        bindings: PatternBindingListSyntax {
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(identifier: .identifier("package")),
                                initializer: InitializerClauseSyntax(
                                    value: FunctionCallExprSyntax(
                                        calledExpression: DeclReferenceExprSyntax(
                                            baseName: .identifier("Package")
                                        ),
                                        leftParen: .leftParenToken(),
                                        arguments: LabeledExprListSyntax {
                                            LabeledExprSyntax(
                                                leadingTrivia: "\n\t",
                                                label: .identifier("name"),
                                                colon: .colonToken(),
                                                expression: StringLiteralExprSyntax(
                                                    openingQuote: .stringQuoteToken(),
                                                    segments: StringLiteralSegmentListSyntax {
                                                        StringSegmentSyntax(
                                                            content: .stringSegment("ESQLEvaluator")
                                                        )
                                                    },
                                                    closingQuote: .stringQuoteToken()
                                                ),
                                                trailingComma: .commaToken()
                                            )
                                            
                                            LabeledExprSyntax(
                                                leadingTrivia: "\n\t",
                                                label: .identifier("platforms"),
                                                colon: .colonToken(),
                                                expression: ArrayExprSyntax(
                                                    elements: ArrayElementListSyntax {
                                                        ArrayElementSyntax(
                                                            expression: FunctionCallExprSyntax(
                                                                calledExpression: MemberAccessExprSyntax(
                                                                    declName: DeclReferenceExprSyntax(
                                                                        baseName: .identifier("macOS")
                                                                    )
                                                                ),
                                                                leftParen: .leftParenToken(),
                                                                arguments: LabeledExprListSyntax {
                                                                    LabeledExprSyntax(
                                                                        expression: MemberAccessExprSyntax(
                                                                            declName: DeclReferenceExprSyntax(
                                                                                baseName: .identifier("v15")
                                                                            )
                                                                        )
                                                                    )
                                                                },
                                                                rightParen: .rightParenToken()
                                                            )
                                                        )
                                                    }
                                                ),
                                                trailingComma: .commaToken()
                                            )
                                            
                                            LabeledExprSyntax(
                                                label: .identifier("dependencies"),
                                                colon: .colonToken(),
                                                expression: ArrayExprSyntax(
                                                    elements: ArrayElementListSyntax {
                                                        ArrayElementSyntax(
                                                            leadingTrivia: "\n\t\t",
                                                            expression: FunctionCallExprSyntax(
                                                                calledExpression: MemberAccessExprSyntax(
                                                                    declName: DeclReferenceExprSyntax(
                                                                        baseName: .identifier("package")
                                                                    )
                                                                ),
                                                                leftParen: .leftParenToken(),
                                                                arguments: LabeledExprListSyntax {
                                                                    LabeledExprSyntax(
                                                                        label: .identifier("url"),
                                                                        colon: .colonToken(),
                                                                        expression: StringLiteralExprSyntax(
                                                                            openingQuote: .stringQuoteToken(),
                                                                            segments: StringLiteralSegmentListSyntax {
                                                                                StringSegmentSyntax(
                                                                                    content: .stringSegment("https://github.com/vapor/postgres-nio.git")
                                                                                )
                                                                            },
                                                                            closingQuote: .stringQuoteToken()
                                                                        ),
                                                                        trailingComma: .commaToken()
                                                                    )
                                                                    
                                                                    LabeledExprSyntax(
                                                                        label: .identifier("from"),
                                                                        colon: .colonToken(),
                                                                        expression: StringLiteralExprSyntax(
                                                                            openingQuote: .stringQuoteToken(),
                                                                            segments: StringLiteralSegmentListSyntax {
                                                                                StringSegmentSyntax(
                                                                                    content: .stringSegment("1.21.0")
                                                                                )
                                                                            },
                                                                            closingQuote: .stringQuoteToken()
                                                                        )
                                                                    )
                                                                },
                                                                rightParen: .rightParenToken()
                                                            ),
                                                            trailingComma: .commaToken()
                                                        )
                                                        
                                                        ArrayElementSyntax(
                                                            leadingTrivia: "\n\t\t",
                                                            expression: FunctionCallExprSyntax(
                                                                calledExpression: MemberAccessExprSyntax(
                                                                    declName: DeclReferenceExprSyntax(
                                                                        baseName: .identifier("package")
                                                                    )
                                                                ),
                                                                leftParen: .leftParenToken(),
                                                                arguments: LabeledExprListSyntax {
                                                                    LabeledExprSyntax(
                                                                        label: .identifier("url"),
                                                                        colon: .colonToken(),
                                                                        expression: StringLiteralExprSyntax(
                                                                            openingQuote: .stringQuoteToken(),
                                                                            segments: StringLiteralSegmentListSyntax {
                                                                                StringSegmentSyntax(
                                                                                    content: .stringSegment("https://github.com/ph1ps/swift-concurrency-deadline.git")
                                                                                )
                                                                            },
                                                                            closingQuote: .stringQuoteToken()
                                                                        ),
                                                                        trailingComma: .commaToken()
                                                                    )
                                                                    
                                                                    LabeledExprSyntax(
                                                                        label: .identifier("from"),
                                                                        colon: .colonToken(),
                                                                        expression: StringLiteralExprSyntax(
                                                                            openingQuote: .stringQuoteToken(),
                                                                            segments: StringLiteralSegmentListSyntax {
                                                                                StringSegmentSyntax(
                                                                                    content: .stringSegment("0.1.1")
                                                                                )
                                                                            },
                                                                            closingQuote: .stringQuoteToken()
                                                                        )
                                                                    )
                                                                },
                                                                rightParen: .rightParenToken()
                                                            ),
                                                            trailingComma: .commaToken()
                                                        )
                                                        
                                                        ArrayElementSyntax(
                                                            leadingTrivia: "\n\t\t",
                                                            expression: FunctionCallExprSyntax(
                                                                calledExpression: MemberAccessExprSyntax(
                                                                    declName: DeclReferenceExprSyntax(
                                                                        baseName: .identifier("package")
                                                                    )
                                                                ),
                                                                leftParen: .leftParenToken(),
                                                                arguments: LabeledExprListSyntax {
                                                                    LabeledExprSyntax(
                                                                        label: .identifier("url"),
                                                                        colon: .colonToken(),
                                                                        expression: StringLiteralExprSyntax(
                                                                            openingQuote: .stringQuoteToken(),
                                                                            segments: StringLiteralSegmentListSyntax {
                                                                                StringSegmentSyntax(
                                                                                    content: .stringSegment("https://github.com/apple/swift-argument-parser.git")
                                                                                )
                                                                            },
                                                                            closingQuote: .stringQuoteToken()
                                                                        ),
                                                                        trailingComma: .commaToken()
                                                                    )
                                                                    
                                                                    LabeledExprSyntax(
                                                                        label: .identifier("from"),
                                                                        colon: .colonToken(),
                                                                        expression: StringLiteralExprSyntax(
                                                                            openingQuote: .stringQuoteToken(),
                                                                            segments: StringLiteralSegmentListSyntax {
                                                                                StringSegmentSyntax(
                                                                                    content: .stringSegment("1.5.0")
                                                                                )
                                                                            },
                                                                            closingQuote: .stringQuoteToken()
                                                                        )
                                                                    )
                                                                },
                                                                rightParen: .rightParenToken()
                                                            ),
                                                            trailingTrivia: "\n\t"
                                                        )

                                                    }
                                                ),
                                                trailingComma: .commaToken()
                                            )
                                            
                                            LabeledExprSyntax(
                                                leadingTrivia: "\n\t",
                                                label: .identifier("targets"),
                                                colon: .colonToken(),
                                                expression: ArrayExprSyntax(
                                                    elements: ArrayElementListSyntax {
                                                        ArrayElementSyntax(
                                                            leadingTrivia: "\n\t\t",
                                                            expression: FunctionCallExprSyntax(
                                                                calledExpression: MemberAccessExprSyntax(
                                                                    declName: DeclReferenceExprSyntax(
                                                                        baseName: .identifier("executableTarget")
                                                                    )
                                                                ),
                                                                leftParen: .leftParenToken(),
                                                                arguments: LabeledExprListSyntax {
                                                                    LabeledExprSyntax(
                                                                        leadingTrivia: "\n\t\t\t",
                                                                        label: .identifier("name"),
                                                                        colon: .colonToken(),
                                                                        expression: StringLiteralExprSyntax(
                                                                            openingQuote: .stringQuoteToken(),
                                                                            segments: StringLiteralSegmentListSyntax {
                                                                                StringSegmentSyntax(
                                                                                    content: .stringSegment("ESQLEvaluator")
                                                                                )
                                                                            },
                                                                            closingQuote: .stringQuoteToken()
                                                                        ),
                                                                        trailingComma: .commaToken()
                                                                    )
                                                                    
                                                                    LabeledExprSyntax(
                                                                        leadingTrivia: "\n\t\t\t",
                                                                        label: .identifier("dependencies"),
                                                                        colon: .colonToken(),
                                                                        expression: ArrayExprSyntax(
                                                                            elements: ArrayElementListSyntax {
                                                                                ArrayElementSyntax(
                                                                                    leadingTrivia: "\n\t\t\t\t",
                                                                                    expression: FunctionCallExprSyntax(
                                                                                        calledExpression: MemberAccessExprSyntax(
                                                                                            declName: DeclReferenceExprSyntax(
                                                                                                baseName: .identifier("product")
                                                                                            )
                                                                                        ),
                                                                                        leftParen: .leftParenToken(),
                                                                                        arguments: LabeledExprListSyntax {
                                                                                            LabeledExprSyntax(
                                                                                                label: .identifier("name"),
                                                                                                colon: .colonToken(),
                                                                                                expression: StringLiteralExprSyntax(
                                                                                                    openingQuote: .stringQuoteToken(),
                                                                                                    segments: StringLiteralSegmentListSyntax {
                                                                                                        StringSegmentSyntax(
                                                                                                            content: .stringSegment("ArgumentParser")
                                                                                                        )
                                                                                                    },
                                                                                                    closingQuote: .stringQuoteToken()
                                                                                                ),
                                                                                                trailingComma: .commaToken()
                                                                                            )
                                                                                            
                                                                                            LabeledExprSyntax(
                                                                                                label: .identifier("package"),
                                                                                                colon: .colonToken(),
                                                                                                expression: StringLiteralExprSyntax(
                                                                                                    openingQuote: .stringQuoteToken(),
                                                                                                    segments: StringLiteralSegmentListSyntax {
                                                                                                        StringSegmentSyntax(
                                                                                                            content: .stringSegment("swift-argument-parser")
                                                                                                        )
                                                                                                    },
                                                                                                    closingQuote: .stringQuoteToken()
                                                                                                )
                                                                                            )
                                                                                        },
                                                                                        rightParen: .rightParenToken()
                                                                                    ),
                                                                                    trailingComma: .commaToken()
                                                                                )
                                                                                
                                                                                ArrayElementSyntax(
                                                                                    leadingTrivia: "\n\t\t\t\t",
                                                                                    expression: FunctionCallExprSyntax(
                                                                                        calledExpression: MemberAccessExprSyntax(
                                                                                            declName: DeclReferenceExprSyntax(
                                                                                                baseName: .identifier("product")
                                                                                            )
                                                                                        ),
                                                                                        leftParen: .leftParenToken(),
                                                                                        arguments: LabeledExprListSyntax {
                                                                                            LabeledExprSyntax(
                                                                                                label: .identifier("name"),
                                                                                                colon: .colonToken(),
                                                                                                expression: StringLiteralExprSyntax(
                                                                                                    openingQuote: .stringQuoteToken(),
                                                                                                    segments: StringLiteralSegmentListSyntax {
                                                                                                        StringSegmentSyntax(
                                                                                                            content: .stringSegment("PostgresNIO")
                                                                                                        )
                                                                                                    },
                                                                                                    closingQuote: .stringQuoteToken()
                                                                                                ),
                                                                                                trailingComma: .commaToken()
                                                                                            )
                                                                                            
                                                                                            LabeledExprSyntax(
                                                                                                label: .identifier("package"),
                                                                                                colon: .colonToken(),
                                                                                                expression: StringLiteralExprSyntax(
                                                                                                    openingQuote: .stringQuoteToken(),
                                                                                                    segments: StringLiteralSegmentListSyntax {
                                                                                                        StringSegmentSyntax(
                                                                                                            content: .stringSegment("postgres-nio")
                                                                                                        )
                                                                                                    },
                                                                                                    closingQuote: .stringQuoteToken()
                                                                                                )
                                                                                            )
                                                                                        },
                                                                                        rightParen: .rightParenToken()
                                                                                    ),
                                                                                    trailingComma: .commaToken()
                                                                                )
                                                                                
                                                                                ArrayElementSyntax(
                                                                                    leadingTrivia: "\n\t\t\t\t",
                                                                                    expression: FunctionCallExprSyntax(
                                                                                        calledExpression: MemberAccessExprSyntax(
                                                                                            declName: DeclReferenceExprSyntax(
                                                                                                baseName: .identifier("product")
                                                                                            )
                                                                                        ),
                                                                                        leftParen: .leftParenToken(),
                                                                                        arguments: LabeledExprListSyntax {
                                                                                            LabeledExprSyntax(
                                                                                                label: .identifier("name"),
                                                                                                colon: .colonToken(),
                                                                                                expression: StringLiteralExprSyntax(
                                                                                                    openingQuote: .stringQuoteToken(),
                                                                                                    segments: StringLiteralSegmentListSyntax {
                                                                                                        StringSegmentSyntax(
                                                                                                            content: .stringSegment("Deadline")
                                                                                                        )
                                                                                                    },
                                                                                                    closingQuote: .stringQuoteToken()
                                                                                                ),
                                                                                                trailingComma: .commaToken()
                                                                                            )
                                                                                            
                                                                                            LabeledExprSyntax(
                                                                                                label: .identifier("package"),
                                                                                                colon: .colonToken(),
                                                                                                expression: StringLiteralExprSyntax(
                                                                                                    openingQuote: .stringQuoteToken(),
                                                                                                    segments: StringLiteralSegmentListSyntax {
                                                                                                        StringSegmentSyntax(
                                                                                                            content: .stringSegment("swift-concurrency-deadline")
                                                                                                        )
                                                                                                    },
                                                                                                    closingQuote: .stringQuoteToken()
                                                                                                )
                                                                                            )
                                                                                        },
                                                                                        rightParen: .rightParenToken()
                                                                                    ),
                                                                                    trailingTrivia: "\n\t\t\t"
                                                                                )
                                                                            }
                                                                        ),
                                                                        trailingTrivia: "\n\t\t"
                                                                    )
                                                                },
                                                                rightParen: .rightParenToken(),
                                                                trailingTrivia: "\n\t"
                                                            )
                                                        )
                                                    }
                                                ),
                                                trailingTrivia: "\n"
                                            )
                                        },
                                        rightParen: .rightParenToken()
                                    )
                                )
                            )
                        }
                    )
                )
            )
        }
    }
    
    public func generateSyntax() -> String {
        let syntax = SourceFileSyntax(
            statements: self.buildSyntax()
        )
        
        return syntax.formatted().description
    }
}
