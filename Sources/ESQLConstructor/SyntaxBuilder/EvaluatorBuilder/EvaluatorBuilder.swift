//
//  EvaluatorBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/27/24.
//  CWID: 10467610
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public struct EvaluatorBuilder: SyntaxBuildable {
    public typealias Parameter = Phi
    
    /// Builds syntax for the `Evaluator` structure
    /// - Parameter phi: The current set of Phi parameters
    /// - Returns: A `StructDeclSyntax` for `Evaluator`
    ///
    /// Consider the following `ESQL` query:
    /// ```sql
    /// select cust, count(NY.quant), sum(NJ.quant), max(CT.quant)
    /// from sales
    /// group by cust; NY, NJ, CT
    /// such that NY.cust = cust and NY.state = 'NY',
    ///           NJ.cust = cust and NJ.state = 'NJ',
    ///           CT.cust = cust and CT.state = 'CT'
    /// ```
    ///
    /// Builds the following syntax:
    /// ```swift
    /// struct Evaluator {
    ///     let service: PostgresService
    ///
    ///     init(service: PostgresService) {
    ///         self.service = service
    ///     }
    ///
    ///     func evaluate() async throws {
    ///         try await withThrowingTaskGroup(of: Void.self) { taskGroup in
    ///             taskGroup.addTask {
    ///                 await self.service.client.run()
    ///             }
    ///
    ///             var results = [MFStruct]()
    ///
    ///             let rows = try await service.query()
    ///
    ///             for try await row in rows.decode(Sales.self) {
    ///                 if !results.exists(cust: row.0) {
    ///                     self.populate(&results, with: row)
    ///                 }
    ///
    ///                 self.computeAggregates(on: &results, using: row)
    ///             }
    ///
    ///             ResultPrinter().print(results)
    ///
    ///             taskGroup.cancelAll()
    ///         }
    ///     }
    ///
    ///     private func populate(_ mfStructs: inout [MFStruct], with row: Sales) {
    ///         let item = MFStruct(
    ///             cust: row.0,
    ///             count_1_quant: .zero,
    ///             sum_2_quant: .zero,
    ///             max_3_quant: Double(Int.min)
    ///         )
    ///
    ///         mfStructs.append(item)
    ///     }
    ///
    ///     private func computeAggregates(on mfStructs: inout [MFStruct], using row: Sales) {
    ///         let index = mfStructs.findIndex(cust: row.0)
    ///
    ///         if (row.5 == "NY") {
    ///             mfStructs[index].count_1_quant += 1
    ///         }
    ///
    ///         if (row.5 == "NJ") {
    ///             mfStructs[index].sum_2_quant += Double(row.6)
    ///         }
    ///
    ///         if (row.5 == "CT") {
    ///             mfStructs[index].max_3_quant = max(mfStructs[index].max_3_quant, Double(row.6))
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// In the presence of a having predicate, the following function is added, as well as a call within `evaluate()` before `ResultPrinter()`.
    /// ```swift
    /// private func applyHavingClause(to mfStructs: inout [MFStruct]) {
    ///     mfStructs = mfStructs.filter({
    ///             /* predicate */
    ///         })
    /// }
    /// ```
    private func buildStructSyntax(with phi: Phi) -> StructDeclSyntax {
        return StructDeclSyntax(
            name: .identifier("Evaluator"),
            memberBlock: MemberBlockSyntax(
                members: MemberBlockItemListSyntax {
                    self.buildPropertySyntax()
                    self.buildInitSyntax()
                    
                    EvaluateFuncBuilder().buildSyntax(with: phi)
                    PopulateFuncBuilder().buildSyntax(with: phi)
                    ComputeFuncBuilder().buildSyntax(with: phi)
                    
                    if let havingPredicate = phi.havingPredicate {
                        HavingFuncBuilder().buildSyntax(with: havingPredicate)
                    }
                }
            )
        )
    }
    
    /// Builds syntax for the properties of `Evaluator`
    /// - Returns: Builds a `VariableDeclSyntax` wrapped in a `MemberBlockItemSyntax`
    ///
    /// Builds the following syntax:
    /// ```swift
    /// let service: PostgresService
    /// ```
    private func buildPropertySyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier("service")
                        ),
                        typeAnnotation: TypeAnnotationSyntax(
                            type: IdentifierTypeSyntax(
                                name: .identifier("PostgresService")
                            )
                        )
                    )
                },
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    /// Builds the `init()` for the `Evaluator` structure
    /// - Returns: An `InitializerDeclSyntax` wrapped in a `MemberBlockItemSyntax`
    ///
    /// Builds the following syntax:
    /// ```swift
    /// init(service: PostgresService) {
    ///     self.service = service
    /// }
    /// ```
    private func buildInitSyntax() -> MemberBlockItemSyntax {
        return MemberBlockItemSyntax(
            decl: InitializerDeclSyntax(
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax(
                        parameters: FunctionParameterListSyntax {
                            FunctionParameterSyntax(
                                firstName: .identifier("service"),
                                type: IdentifierTypeSyntax(
                                    name: .identifier("PostgresService")
                                )
                            )
                        }
                    )
                ),
                body: CodeBlockSyntax(
                    statements: CodeBlockItemListSyntax {
                        InfixOperatorExprSyntax(
                            leftOperand: MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(
                                    baseName: .keyword(.self)
                                ),
                                declName: DeclReferenceExprSyntax(
                                    baseName: .identifier("service")
                                )
                            ),
                            operator: AssignmentExprSyntax(),
                            rightOperand: DeclReferenceExprSyntax(
                                baseName: .identifier("service")
                            )
                        )
                    }
                ),
                trailingTrivia: .newlines(2)
            )
        )
    }
    
    public func generateSyntax(with param: Phi) -> String {
        let foundationImportDecl = self.buildImportSyntax(.foundation, leadingTrivia: self.commentHeader)
        let spectreImportDecl = self.buildImportSyntax(.spectreKit, trailingTrivia: .newlines(2))
        let typealiasDecl = SalesTypealiasBuilder().buildSyntax()
        let evaluatorDecl = self.buildStructSyntax(with: param)
        
        return self.generateSyntaxBuilder {
            foundationImportDecl
            spectreImportDecl
            typealiasDecl
            evaluatorDecl
        }
    }
}
