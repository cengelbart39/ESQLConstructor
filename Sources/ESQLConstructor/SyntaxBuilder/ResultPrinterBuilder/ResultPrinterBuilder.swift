//
//  ResultPrinterBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/14/24.
//  CWID: 10467610
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

struct ResultPrinterBuilder: SyntaxBuildable {
    typealias Parameter = Phi
    
    /// Builds syntax for `ResultPrinter`, used for printing results
    /// - Parameter phi: The current set of phi parameters
    /// - Returns: The syntax as a `StructDeclSyntax`
    ///
    /// Builds the following syntax:
    /// ```swift
    /// struct ResultPrinter {
    ///     func print(_ mfStructs: [MFStruct]) {
    ///         let console = Console()
    ///
    ///         var table = Table()
    ///         self.makeColumns(in: &table)
    ///
    ///         for item in mfStructs {
    ///             self.makeRow(in: &table, as: item)
    ///         }
    ///
    ///         console.write(table)
    ///     }
    ///
    ///     private func makeColumns(in table: inout Table) {
    ///         table.addColumns("cust", "avg_1_quant", "sum_2_quant", "max_3_quant")
    ///     }
    ///
    ///     private func makeRow(in table: inout Table, as mfStruct: MFStruct) {
    ///         let text0 = Text("\(mfStruct.cust)").justify(.left)
    ///         let text1 = Text("\(mfStruct.avg_1_quant)").justify(.right)
    ///         let text2 = Text("\(mfStruct.sum_2_quant.format())").justify(.right)
    ///         let text3 = Text("\(mfStruct.max_3_quant.format())").justify(.right)
    ///
    ///         table.addRow(text0, text1, text2, text3)
    ///
    ///     }
    /// }
    /// ```
    func buildSyntax(with phi: Phi) -> StructDeclSyntax {
        return StructDeclSyntax(
            // struct
            structKeyword: .keyword(.struct),
            // ResultPrinter
            name: .identifier("ResultPrinter"),
            memberBlock: MemberBlockSyntax(
                // {
                leftBrace: .leftBraceToken(),
                members: MemberBlockItemListSyntax {
                    // func print(_:) { ... }
                    PrintFuncBuilder().buildSyntax()
                    
                    // func makeColumns(in:) { ... }
                    MakeColumnsFuncBuilder().buildSyntax(with: phi)
                    
                    // func makeRow(in:as:)
                    MakeRowFuncBuilder().buildSyntax(with: phi)
                },
                // }
                rightBrace: .rightBraceToken()
            )
        )
    }
            
    func generateSyntax(with param: Phi) -> String {
        let foundationImport = self.buildImportSyntax(.foundation, leadingTrivia: self.commentHeader)
        let spectreImport = self.buildImportSyntax(.spectreKit, trailingTrivia: .newlines(2))
        let structDecl = self.buildSyntax(with: param)
        
        return self.generateSyntaxBuilder {
            foundationImport
            spectreImport
            structDecl
        }
    }
}
