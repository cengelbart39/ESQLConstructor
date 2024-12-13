//
//  PackageFileBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/25/24.
//  CWID: 10467610
//

import Foundation
import SwiftSyntax

public struct PackageFileBuilder: SyntaxBuildable {
    public typealias Parameter = Void
    
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
    ///     name: "ESQLEvaluator",
    ///     platforms: [.macOS(.v15)],
    ///     dependencies: [
    ///         .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.21.0",),
    ///         .package(url: "https://github.com/ph1ps/swift-concurrency-deadline.git", from: "0.1.1",),
    ///         .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    ///         .package(url: "https://github.com/patriksvensson/spectre-kit.git", branch: "main")
    ///     ],
    ///     targets: [
    ///         .executableTarget(
    ///             name: "ESQLEvaluator",
    ///             dependencies: [
    ///                 .product(name: "ArgumentParser", package: "swift-argument-parser"),
    ///                 .product(name: "PostgresNIO", package: "postgres-nio"),
    ///                 .product(name: "Deadline", package: "swift-concurrency-deadline"),
    ///                 .product(name: "SpectreKit", package: "spectre-kit")
    ///             ]
    ///         )
    ///     ]
    ///)
    /// ```
    private func buildSyntax() -> CodeBlockItemListSyntax {
        return CodeBlockItemListSyntax {
            
            // // swift-tools-version: 6.0
            // import PackageDescription
            self.buildImportSyntax(
                .packageDescription,
                leadingTrivia: .lineComment("// swift-tools-version: 6.0").merging(.newline).merging(.lineComment("// Christopher Engelbart")).merging(.newline).merging(.lineComment("// CWID: 10467610")).merging(.newlines(2)),
                trailingTrivia: .newlines(2)
            )
            
            // Rest
            VariableDeclSyntax(
                leadingTrivia: .newline,
                // let
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // package
                        pattern: IdentifierPatternSyntax(identifier: .identifier("package")),
                        initializer: InitializerClauseSyntax(
                            // =
                            equal: .equalToken(),
                            value: FunctionCallExprSyntax(
                                // Package
                                calledExpression: DeclReferenceExprSyntax(
                                    baseName: .identifier("Package")
                                ),
                                // (
                                leftParen: .leftParenToken(),
                                // Body
                                arguments: LabeledExprListSyntax {
                                    self.buildNameSyntax()
                                    
                                    self.buildPlatformsSyntax()
                                    
                                    self.buildDependenciesSyntax()
                                    
                                    self.buildTargetSyntax()
                                },
                                // )
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                }
            )
        }
    }
    
    /// Builds a `LabeledExprSyntax` for the package name
    /// - Returns: The `Package`'s name
    ///
    /// Builds the following syntax:
    /// ```swift
    /// name: "ESQLEvaluator",
    /// ```
    private func buildNameSyntax() -> LabeledExprSyntax {
        return LabeledExprSyntax(
            leadingTrivia: .newline.merging(.tab),
            // name
            label: .identifier("name"),
            // :
            colon: .colonToken(),
            // "ESQLEvaluator"
            expression: StringLiteralExprSyntax(
                openingQuote: .stringQuoteToken(),
                segments: StringLiteralSegmentListSyntax {
                    StringSegmentSyntax(
                        content: .stringSegment("ESQLEvaluator")
                    )
                },
                closingQuote: .stringQuoteToken()
            ),
            // ,
            trailingComma: .commaToken()
        )
    }
    
    /// Builds a `LabeledExprSyntax` for the package's supported platforms
    /// - Returns: The `Package`'s supported platforms
    ///
    /// Builds the following syntax:
    /// ```swift
    /// platforms: [.macOS(.v15)],
    /// ```
    private func buildPlatformsSyntax() -> LabeledExprSyntax {
        return LabeledExprSyntax(
            leadingTrivia: .newline.merging(.tab),
            // platforms
            label: .identifier("platforms"),
            // :
            colon: .colonToken(),
            // [
            expression: ArrayExprSyntax(
                elements: ArrayElementListSyntax {
                    ArrayElementSyntax(
                        expression: FunctionCallExprSyntax(
                            // .macOS
                            calledExpression: MemberAccessExprSyntax(
                                declName: DeclReferenceExprSyntax(
                                    baseName: .identifier("macOS")
                                )
                            ),
                            // (
                            leftParen: .leftParenToken(),
                            // .v15
                            arguments: LabeledExprListSyntax {
                                LabeledExprSyntax(
                                    expression: MemberAccessExprSyntax(
                                        declName: DeclReferenceExprSyntax(
                                            baseName: .identifier("v15")
                                        )
                                    )
                                )
                            },
                            // )
                            rightParen: .rightParenToken()
                        )
                    )
                }
            ),
            // ]
            trailingComma: .commaToken()
        )
    }
    
    /// Builds a `LabeledExprSyntax` for the package's dependencies
    /// - Returns: The `Package`'s package's dependencies
    ///
    /// Builds the following syntax:
    /// ```swift
    /// dependencies: [
    ///     .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.21.0"),
    ///     .package(url: "https://github.com/ph1ps/swift-concurrency-deadline.git", from: "0.1.1"),
    ///     .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    ///     .package(url: "https://github.com/patriksvensson/spectre-kit.git", branch: "main")
    /// ],
    /// ```
    private func buildDependenciesSyntax() -> LabeledExprSyntax {
        return LabeledExprSyntax(
            leadingTrivia: .newline.merging(.tab),
            // dependencies
            label: .identifier("dependencies"),
            // :
            colon: .colonToken(),
            // [
            expression: ArrayExprSyntax(
                elements: ArrayElementListSyntax {
                    // .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.21.0"),
                    self.buildPackageDependencySyntax(
                        url: "https://github.com/vapor/postgres-nio.git",
                        location: "1.21.0",
                        locationType: .version,
                        trailingTrivia: .commaToken()
                    )
                    
                    // .package(url: "https://github.com/ph1ps/swift-concurrency-deadline.git", from: "0.1.1"),
                    self.buildPackageDependencySyntax(
                        url: "https://github.com/ph1ps/swift-concurrency-deadline.git",
                        location: "0.1.1",
                        locationType: .version,
                        trailingTrivia: .commaToken()
                    )
                    
                    // .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0")
                    self.buildPackageDependencySyntax(
                        url: "https://github.com/apple/swift-argument-parser.git",
                        location: "1.5.0",
                        locationType: .version,
                        trailingTrivia: .commaToken()
                    )
                    
                    // .package(url: "https://github.com/patriksvensson/spectre-kit.git", branch: "main")
                    self.buildPackageDependencySyntax(
                        url: "https://github.com/patriksvensson/spectre-kit.git",
                        location: "main",
                        locationType: .branch
                    )
                }
            ),
            // ],
            trailingComma: .commaToken()
        )
    }
    
    private enum PackageLocation: String {
        case version = "from"
        case branch = "branch"
    }
    
    /// Builds an `ArrayElementSyntax` to fetch a Swift package at a remote repository
    /// - Parameters:
    ///   - url: The repository URL
    ///   - version: The package version
    ///   - trailingTrivia: Any trailing trivia used
    /// - Returns: An expression to where to fetch the package at `url`  from `verison`
    ///
    /// Builds the syntax for the following format:
    /// ```swift
    /// .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.21.0")
    /// ```
    private func buildPackageDependencySyntax(
        url: String,
        location: String,
        locationType: PackageLocation,
        trailingTrivia: TokenSyntax? = nil
    ) -> ArrayElementSyntax {
        return ArrayElementSyntax(
            leadingTrivia: .newline.merging(.tabs(2)),
            expression: FunctionCallExprSyntax(
                // .package
                calledExpression: MemberAccessExprSyntax(
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("package")
                    )
                ),
                // (
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        // url
                        label: .identifier("url"),
                        // :
                        colon: .colonToken(),
                        // "<url>"
                        expression: StringLiteralExprSyntax(
                            openingQuote: .stringQuoteToken(),
                            segments: StringLiteralSegmentListSyntax {
                                StringSegmentSyntax(
                                    content: .stringSegment(url)
                                )
                            },
                            closingQuote: .stringQuoteToken()
                        ),
                        // ,
                        trailingComma: .commaToken()
                    )
                    
                    LabeledExprSyntax(
                        // from
                        label: .identifier(locationType.rawValue),
                        // :
                        colon: .colonToken(),
                        // "<version>"
                        expression: StringLiteralExprSyntax(
                            openingQuote: .stringQuoteToken(),
                            segments: StringLiteralSegmentListSyntax {
                                StringSegmentSyntax(
                                    content: .stringSegment(location)
                                )
                            },
                            closingQuote: .stringQuoteToken()
                        )
                    )
                },
                // )
                rightParen: .rightParenToken()
            ),
            trailingComma: trailingTrivia
        )

    }
    
    /// Builds a `LabeledExprSyntax` for the package's target
    /// - Returns: The `Package`'s package's target
    ///
    /// Builds the following syntax:
    /// ```swift
    /// targets: [
    ///     .executableTarget(
    ///         name: "ESQLEvaluator",
    ///         dependencies: [
    ///             .product(name: "ArgumentParser", package: "swift-argument-parser"),
    ///             .product(name: "PostgresNIO", package: "postgres-nio"),
    ///             .product(name: "Deadline", package: "swift-concurrency-deadline"),
    ///             .product(name: "SpectreKit", package: "spectre-kit")
    ///         ]
    ///     )
    /// ]
    /// ```
    private func buildTargetSyntax() -> LabeledExprSyntax {
        return LabeledExprSyntax(
            leadingTrivia: .newline.merging(.tab),
            // targets
            label: .identifier("targets"),
            // :
            colon: .colonToken(),
            // [
            expression: ArrayExprSyntax(
                elements: ArrayElementListSyntax {
                    ArrayElementSyntax(
                        leadingTrivia: .newline.merging(.tabs(2)),
                        expression: FunctionCallExprSyntax(
                            // .executableTarget
                            calledExpression: MemberAccessExprSyntax(
                                declName: DeclReferenceExprSyntax(
                                    baseName: .identifier("executableTarget")
                                )
                            ),
                            // (
                            leftParen: .leftParenToken(),
                            arguments: LabeledExprListSyntax {
                                LabeledExprSyntax(
                                    leadingTrivia: .newline.merging(.tabs(3)),
                                    // name
                                    label: .identifier("name"),
                                    // :
                                    colon: .colonToken(),
                                    // "ESQLEvaluator"
                                    expression: StringLiteralExprSyntax(
                                        openingQuote: .stringQuoteToken(),
                                        segments: StringLiteralSegmentListSyntax {
                                            StringSegmentSyntax(
                                                content: .stringSegment("ESQLEvaluator")
                                            )
                                        },
                                        closingQuote: .stringQuoteToken()
                                    ),
                                    // ,
                                    trailingComma: .commaToken()
                                )
                                
                                LabeledExprSyntax(
                                    leadingTrivia: .newline.merging(.tabs(3)),
                                    // dependencies
                                    label: .identifier("dependencies"),
                                    // :
                                    colon: .colonToken(),
                                    // [
                                    expression: ArrayExprSyntax(
                                        elements: ArrayElementListSyntax {
                                            // .product(name: "ArgumentParser", package: "swift-argument-parser"),
                                            self.buildProductDependencySyntax(
                                                moduleName: "ArgumentParser",
                                                packageName: "swift-argument-parser",
                                                trailingTrivia: .commaToken()
                                            )
                                            
                                            // .product(name: "PostgresNIO", package: "postgres-nio"),
                                            self.buildProductDependencySyntax(
                                                moduleName: "PostgresNIO",
                                                packageName: "postgres-nio",
                                                trailingTrivia: .commaToken()
                                            )
                                                           
                                            // .product(name: "Deadline", package: "swift-concurrency-deadline")
                                            self.buildProductDependencySyntax(
                                                moduleName: "Deadline",
                                                packageName: "swift-concurrency-deadline"
                                            )
                                            
                                            // .product(name: "SpectreKit", package: "spectre-kit")
                                            self.buildProductDependencySyntax(
                                                moduleName: "SpectreKit",
                                                packageName: "spectre-kit"
                                            )
                                        }
                                    ),
                                    // ]
                                    trailingTrivia: .newline.merging(.tabs(2))
                                )
                            },
                            // )
                            rightParen: .rightParenToken(),
                            trailingTrivia: .newline.merging(.tab)
                        )
                    )
                }
            ),
            // ]
            trailingTrivia: .newline
        )
    }
    
    /// Builds an `ArrayElementSyntax` to assign a package product to a target
    /// - Parameters:
    ///   - moduleName: The name of the module belonging to the package
    ///   - packageName: The name of the package
    ///   - trailingTrivia: Any trailing trivia used
    /// - Returns: An expression of where a module comes from
    ///
    /// Builds the syntax for the following format:
    /// ```swift
    /// .product(name: "ArgumentParser", package: "swift-argument-parser")
    /// ```
    private func buildProductDependencySyntax(
        moduleName: String,
        packageName: String,
        trailingTrivia: TokenSyntax? = nil
    ) -> ArrayElementSyntax {
        return ArrayElementSyntax(
            leadingTrivia: .newline.merging(.tabs(4)),
            expression: FunctionCallExprSyntax(
                // .product
                calledExpression: MemberAccessExprSyntax(
                    declName: DeclReferenceExprSyntax(
                        baseName: .identifier("product")
                    )
                ),
                // (
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                        // name
                        label: .identifier("name"),
                        // :
                        colon: .colonToken(),
                        // "<moduleName>"
                        expression: StringLiteralExprSyntax(
                            openingQuote: .stringQuoteToken(),
                            segments: StringLiteralSegmentListSyntax {
                                StringSegmentSyntax(
                                    content: .stringSegment(moduleName)
                                )
                            },
                            closingQuote: .stringQuoteToken()
                        ),
                        // ,
                        trailingComma: .commaToken()
                    )
                    
                    LabeledExprSyntax(
                        // package
                        label: .identifier("package"),
                        // :
                        colon: .colonToken(),
                        // "<packageName>"
                        expression: StringLiteralExprSyntax(
                            openingQuote: .stringQuoteToken(),
                            segments: StringLiteralSegmentListSyntax {
                                StringSegmentSyntax(
                                    content: .stringSegment(packageName)
                                )
                            },
                            closingQuote: .stringQuoteToken()
                        )
                    )
                },
                // )
                rightParen: .rightParenToken()
            ),
            trailingComma: trailingTrivia
        )

    }

    public func generateSyntax(with param: Void = Void()) -> String {
        let packageSyntax = self.buildSyntax()
        
        return self.generateSyntaxBuilder {
            packageSyntax
        }
    }
}
