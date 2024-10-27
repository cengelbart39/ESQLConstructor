//
//  Sales.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/27/24.
//

import Foundation
import PostgresNIO
import SwiftSyntax

typealias SalesSchema = (String, String, Int, Int, Int, String, Int, Date)

struct Sales {
    let cust: String
    let prod: String
    let day: Int
    let month: Int
    let year: Int
    let state: String
    let quant: Int
    let date: Date
    
    init(_ row: SalesSchema) {
        self.cust = row.0
        self.prod = row.1
        self.day = row.2
        self.month = row.3
        self.year = row.4
        self.state = row.5
        self.quant = row.6
        self.date = row.7
    }
}
