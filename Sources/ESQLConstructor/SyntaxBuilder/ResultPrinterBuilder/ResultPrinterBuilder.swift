//
//  ResultPrinterBuilder.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 11/14/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

struct ResultPrinterBuilder: SyntaxBuildable {
    typealias Parameter = Phi
    
    func buildSyntax(with phi: Phi) -> StructDeclSyntax {
        return StructDeclSyntax(
            structKeyword: .keyword(.struct),
            name: .identifier("ResultPrinter"),
            memberBlock: MemberBlockSyntax(
                leftBrace: .leftBraceToken(),
                members: MemberBlockItemListSyntax {
                    PrintFuncBuilder().buildSyntax()
                    MakeColumnsFuncBuilder().buildSyntax(with: phi)
                    MakeRowFuncBuilder().buildSyntax(with: phi)
                },
                rightBrace: .rightBraceToken()
            )
        )
    }
            
    func generateSyntax(with param: Phi) -> String {
        let foundationImport = self.buildImportSyntax(.foundation)
        let spectreImport = self.buildImportSyntax(.spectreKit, trailingTrivia: .newlines(2))
        let structDecl = self.buildSyntax(with: param)
        
        return self.generateSyntaxBuilder {
            foundationImport
            spectreImport
            structDecl
        }
    }
}
