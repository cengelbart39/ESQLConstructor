//
//  File.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/24/24.
//

import Foundation

public struct FileHandler {
    /// Retrieves the contents of a file
    /// - Parameter strUrl: The file url as a String
    /// - Throws: Can throw ``ReadError``
    /// - Returns: The contents of the file
    public static func read(from strUrl: String) throws -> String {
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
    
    public static func write(_ code: String) throws {
        let url = URL(filePath: "/Users/christopher/Developer/output.swift")
        
        do {
            try code.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            throw WriteError.write(error.localizedDescription)
        }
    }
    
    public enum ReadError: Error {
        case dataConversion(String)
        case stringConversion
    }
    
    public enum WriteError: Error {
        case write(String)
    }
}


