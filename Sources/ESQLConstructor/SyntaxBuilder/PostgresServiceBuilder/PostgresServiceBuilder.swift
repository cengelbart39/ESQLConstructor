//
//  PostgresServiceBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/26/24.
//

import SwiftSyntax

public struct PostgresServiceBuilder: SyntaxBuildable {
    public typealias Parameter = PostgresService
    
    /**
     Builds the syntax for the whole `PostgresService` struct
     - Parameter service: A local version of ``PostgresService`` for database credentials
     
     Builds the following syntax, where DB credentials come from `service`:
     ```swift
     struct PostgresService: Sendable {
         let client: PostgresClient

         init() {
             let config = PostgresClient.Configuration(host: "localhost", port: 5432, username: "username", password: "password", database: "database", tls: .disable)
             self.client = PostgresClient(configuration: config)
         }

         func query() async throws -> PostgresRowSequence {
             return try await withDeadline(until: .now + .seconds(15)) {
                 try await self.client.query("select * from sales")
             }
         }
     }
     ```
     */
    private func buildStructSyntax(with service: PostgresService) -> StructDeclSyntax {
        return StructDeclSyntax(
            // struct
            structKeyword: .keyword(.struct),
            // PostgresService
            name: .identifier("PostgresService"),
            inheritanceClause: InheritanceClauseSyntax(
                // :
                colon: .colonToken(),
                inheritedTypes: InheritedTypeListSyntax {
                    // Sendable
                    InheritedTypeSyntax(
                        type: IdentifierTypeSyntax(
                            name: .identifier("Sendable")
                        )
                    )
                }
            ),
            memberBlock: MemberBlockSyntax(
                // {
                leftBrace: .leftBraceToken(),
                members: MemberBlockItemListSyntax {
                    // let client: PostgresService
                    self.buildFieldSyntax()
                    
                    // init() { ... }
                    InitBuilder().buildSyntax(with: service)
                    
                    // query(_:until:) {... }
                    QueryFuncBuilder().buildSyntax()
                },
                // }
                rightBrace: .rightBraceToken()
            )
        )
    }
    
    private func buildFieldSyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: VariableDeclSyntax(
                // let
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        // client
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("client")
                        ),
                        // : PostgresClient
                        typeAnnotation: TypeAnnotationSyntax(
                            colon: .colonToken(),
                            type: IdentifierTypeSyntax(
                                name: "PostgresClient"
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    /**
     Generates the syntax for the output version of `PostgresService`
     - Parameter service: A ``PostgresService`` that contains the database credentials
     - Returns: The formatted code for the output
     */
    public func generateSyntax(with param: PostgresService) -> String {
        let import1 = self.buildImportSyntax(.deadline)
        let import2 = self.buildImportSyntax(.postgresNIO, leadingTrivia: .newlines(2))
        let serviceStruct = self.buildStructSyntax(with: param)
        
        return self.generateSyntaxBuilder {
            import1
            import2
            serviceStruct
        }
    }
}
