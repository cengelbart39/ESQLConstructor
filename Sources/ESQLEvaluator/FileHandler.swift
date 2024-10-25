//
//  File.swift
//  ESQLEvaluator
//
//  Created by Christopher Engelbart on 10/24/24.
//

import Foundation

struct FileHandler {
    /// Retrieves the contents of a file
    /// - Parameter strUrl: The file url as a String
    /// - Throws: Can throw ``ReadError``
    /// - Returns: The contents of the file
    static func read(_ strUrl: String) throws -> String {
        /// Get a `URL` from the passed in string
        let url = URL(filePath: strUrl)
        
        /// Attempt to extract data from the URL
        let data: Data
        
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ReadError.dataConversion(error.localizedDescription)
        }
        
        /// Attempt to convert file data into a string
        guard let string = String(data: data, encoding: .utf8) else {
            throw ReadError.stringConversion
        }
        
        return string
    }
}

enum ReadError: Error {
    case dataConversion(String)
    case stringConversion
}
