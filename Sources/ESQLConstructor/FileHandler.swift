//
//  FileHandler.swift
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
            throw FileError.dataConversion(error.localizedDescription)
        }
        
        /// Attempt to convert file data into a string
        guard let string = String(data: data, encoding: .utf8) else {
            throw FileError.stringConversion
        }
        
        return string
    }
    
    public static func write(_ code: String, to path: String) throws {
        let url = URL(filePath: path)
        
        do {
            try code.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            throw FileError.write(error.localizedDescription)
        }
    }
    
    public static func createDirectory(at path: String) throws {
        let url = URL(filePath: path)
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            throw FileError.createDirectory(error.localizedDescription)
        }
    }
    
    
    public enum FileError: Error {
        case dataConversion(String)
        case stringConversion
        case write(String)
        case createDirectory(String)
    }
}

public extension FileHandler {
    static func createOutputFiles(at path: String, with phi: Phi, using service: PostgresService) throws {
        let rootUrl = path + "/ESQLEvaluator"
        try FileHandler.createDirectory(at: rootUrl)
        
        let packageFileUrl = rootUrl.appending("/Package.swift")
        let packageFile = PackageFileBuilder().generateSyntax()
        try FileHandler.write(packageFile, to: packageFileUrl)
        
        let sourcesUrl = rootUrl.appending("/Sources")
        try FileHandler.createDirectory(at: sourcesUrl)
        
        let evaluatorUrl = sourcesUrl.appending("/ESQLEvaluator")
        try FileHandler.createDirectory(at: evaluatorUrl)
        
        let mfStructUrl = evaluatorUrl.appending("/MFStruct.swift")
        let mfStructFile = MFStructBuilder().generateSyntax(with: phi)
        try FileHandler.write(mfStructFile, to: mfStructUrl)
        
        let postgresServiceUrl = evaluatorUrl.appending("/PostgresService.swift")
        let postgresServiceFile = PostgresServiceBuilder().generateSyntax(with: service)
        try FileHandler.write(postgresServiceFile, to: postgresServiceUrl)
    }
    
    static func constructPhi(from filePath: String) throws -> Phi {
        let contents = try FileHandler.read(from: filePath)
        let phi = try Phi(string: contents)
        return phi
    }
}
