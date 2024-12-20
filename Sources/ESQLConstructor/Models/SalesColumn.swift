//
//  SalesColumn.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/24/24.
//  CWID: 10467610
//

import Foundation

/// An enum that represents the schema of the `sales` table
public enum SalesColumn: String, CaseIterable {
    // Map enum case to column name
    case customer = "cust"
    case product = "prod"
    case day = "day"
    case month = "month"
    case year = "year"
    case state = "state"
    case quantity = "quant"
    case date = "date"
    
    /// The appropriate type for a given column
    public var type: SalesDataType {
        switch self {
        case .customer, .product, .state:
            return .string
        case .day, .month, .year, .quantity:
            return .double
        case .date:
            return .date
        }
    }
    
    /// Maps enum case to column number
    public var tupleNum: String {
        switch self {
        case .customer:
            return "0"
        case .product:
            return "1"
        case .day:
            return "2"
        case .month:
            return "3"
        case .year:
            return "4"
        case .state:
            return "5"
        case .quantity:
            return "6"
        case .date:
            return "7"
        }
    }
}

public enum SalesDataType: String {
    case string = "String"
    case double = "Double"
    case average = "Average"
    case date = "Date"
}
