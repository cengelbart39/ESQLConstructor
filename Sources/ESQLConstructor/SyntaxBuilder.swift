//
//  SyntaxBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/24/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public struct SyntaxBuilder {
    public init() { }
    
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
    private func generatePackageFile() -> CodeBlockItemListSyntax {
        return CodeBlockItemListSyntax {
            CodeBlockItemSyntax(
                leadingTrivia: .lineComment("// swift-tools-version: 6.0 \n\n"),
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
                                                leadingTrivia: "\n\t",
                                                label: .identifier("products"),
                                                colon: .colonToken(),
                                                expression: ArrayExprSyntax {
                                                    ArrayElementListSyntax {
                                                        ArrayElementSyntax(
                                                            leadingTrivia: "\n\t\t",
                                                            expression: FunctionCallExprSyntax(
                                                                calledExpression: MemberAccessExprSyntax(
                                                                    declName: DeclReferenceExprSyntax(
                                                                        baseName: .identifier("library")
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
                                                                        label: .identifier("targets"),
                                                                        colon: .colonToken(),
                                                                        expression: ArrayExprSyntax(
                                                                            elements: ArrayElementListSyntax {
                                                                                ArrayElementSyntax(
                                                                                    expression: StringLiteralExprSyntax(
                                                                                        openingQuote: .stringQuoteToken(),
                                                                                        segments: StringLiteralSegmentListSyntax {
                                                                                            StringSegmentSyntax(
                                                                                                content: .stringSegment("ESQLEvaluator")
                                                                                            )
                                                                                        },
                                                                                        closingQuote: .stringQuoteToken()
                                                                                    )
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
                                                },
                                                trailingComma: .commaToken(),
                                                trailingTrivia: "\n\t"
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
                                                                        ),
                                                                        trailingComma: .commaToken()
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
                                                                        ),
                                                                        trailingComma: .commaToken()
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
    
    /**
     Creates a `CodeBlockItemSyntax` for imported modules
     
     Syntax for the following imports:
     ```swift
     import Foundation
     ```
     */
    private func generateImports() -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                ImportDeclSyntax(
                    path: ImportPathComponentListSyntax {
                        ImportPathComponentSyntax(name: .identifier("Foundation"))
                    }
                )
            )
        )
    }
    
    
    /// Generates a `CodeBlockItemSyntax` for an `MFStruct`
    /// - Parameter phi: Parameters for the Phi operator
    /// - Returns: A `MFStruct` according to the `[ProjectedValue]` in `Phi`
    ///
    /// If ``Phi`` contains the projected values `cust`, `count(1.quant)`, `sum(2.quant)`, and `max(3.quant)`,
    /// it will return a `CodeBlockItemSyntax` for:
    /// ```swift
    /// struct MFStruct {
    ///     let cust: String
    ///     let count_1_quant: Double
    ///     let sum_2_quant: Double
    ///     let max_3_quant: Double
    /// }
    /// ```
    private func generateMFStruct(with phi: Phi) -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: CodeBlockItemSyntax.Item(
                StructDeclSyntax(
                    name: "MFStruct",
                    memberBlock: MemberBlockSyntax(
                        members: MemberBlockItemListSyntax {
                            for value in phi.projectedValues {
                                MemberBlockItemSyntax(
                                    decl: VariableDeclSyntax(
                                        bindingSpecifier: .keyword(.let),
                                        bindings: PatternBindingListSyntax {
                                            PatternBindingSyntax(
                                                pattern: IdentifierPatternSyntax(
                                                    identifier: .identifier(value.name)
                                                ),
                                                typeAnnotation: TypeAnnotationSyntax(
                                                    type: IdentifierTypeSyntax(
                                                        name: .identifier(value.type)
                                                    )
                                                )
                                            )
                                        }
                                    )
                                )
                            }
                        }
                    )
                )
            )
        )
    }
    
    public func generateCode(with phi: Phi) -> String {
        let syntax = SourceFileSyntax(
            statements: CodeBlockItemListSyntax {
                self.generateImports()
                self.generateMFStruct(with: phi)
            }
        )
        
        return syntax.formatted().description
    }
}
