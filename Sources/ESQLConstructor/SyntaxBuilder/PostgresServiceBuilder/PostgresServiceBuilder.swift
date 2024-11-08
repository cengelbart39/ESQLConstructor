//
//  PostgresServiceBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/26/24.
//

import SwiftSyntax

/**
 A syntax builder and generate that creates an output varation of `PostgresService`
 
 This produces the below code. Note that the `PostgresClient.Configuration` can vary due to input, where both `password` and `database` can be `nil`
 ```swift
 import PostgresNIO
 import Deadline

 struct PostgresService: Sendable {
     let client: PostgresClient

     init() {
         let config = PostgresClient.Configuration(host: "localhost", port: 5432, username: "username", password: "password", database: "database", tls: .disable)
         self.client = PostgresClient(configuration: config)
     }

     func query(_ query: PostgresQuery, until seconds: Int) async throws -> PostgresRowSequence {
         return try await withDeadline(until: .now + .seconds(seconds)) {
             try await self.client.query(query)
         }
     }

     func connectAndRun(operation: () async throws -> Void) async throws {
         try await withThrowingTaskGroup(of: Void.self) { taskGroup in
             taskGroup.addTask {
                 await self.client.run()
             }
             try await operation()
             taskGroup.cancelAll()
         }
     }
 }
 ```
 */
public struct PostgresServiceBuilder: SyntaxBuildable {
    public typealias Parameter = PostgresService
    
    /**
     Builds the syntax for the whole `PostgresService` struct
     - Parameter service: A local version of ``PostgresService`` for database credentials
     */
    private func buildStructSyntax(with service: PostgresService) -> StructDeclSyntax {
        return StructDeclSyntax(
                        name: .identifier("PostgresService"),
                        inheritanceClause: InheritanceClauseSyntax(
                            inheritedTypes: InheritedTypeListSyntax {
                                InheritedTypeSyntax(
                                    type: IdentifierTypeSyntax(
                                        name: .identifier("Sendable")
                                    )
                                )
                            }
                        ),
                        memberBlock: MemberBlockSyntax(
                            members: MemberBlockItemListSyntax {
                                self.buildFieldSyntax()
                                
                                InitBuilder().buildSyntax(with: service)
                                
                                QueryFuncBuilder().buildSyntax()
                            }
                        )
                    )
    }
    
    private func buildFieldSyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("client")
                        ),
                        typeAnnotation: TypeAnnotationSyntax(
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
