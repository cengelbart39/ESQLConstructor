//
//  FileHandler.swift
//  ESQLConstructor
//
//  Created by Christopher Engelbart on 10/24/24.
//  CWID: 10467610
//

import Foundation

public struct FileHandler {
    /// Retrieves the contents of a file
    /// - Parameter strUrl: The file url as a String
    /// - Throws: Can throw ``FileError``
    /// - Returns: The contents of the file
    public static func read(from strUrl: String) throws -> String {
        // Get a `URL` from the passed in string
        let url = URL(filePath: strUrl)
        
        // Attempt to extract data from the URL
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
    
    /// Writes a file to the specified path
    /// - Parameters:
    ///   - code: What needs to be written to a file
    ///   - path: Where the file should be written
    public static func write(_ code: String, to path: String) throws {
        let url = URL(filePath: path)
        
        do {
            try code.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            throw FileError.write(error.localizedDescription)
        }
    }
    
    /// Creates a directory at the specified path
    /// - Parameter path: Where to write the file and what it is called
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
    
    /// Creates the output Swift package
    /// - Parameters:
    ///   - path: Where to write the root of the output files
    ///   - phi: The set of `Phi` parameters
    ///   - service: The database credentials
    public static func createOutputFiles(at path: String, with phi: Phi, using service: PostgresService) throws {
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
        
        if phi.aggregates.hasAverage() {
            let avgUrl = evaluatorUrl.appending("/Average.swift")
            let avgFile = AverageBuilder().generateSyntax()
            try FileHandler.write(avgFile, to: avgUrl)
        }
        
        let postgresServiceUrl = evaluatorUrl.appending("/PostgresService.swift")
        let postgresServiceFile = PostgresServiceBuilder().generateSyntax(with: service)
        try FileHandler.write(postgresServiceFile, to: postgresServiceUrl)
        
        let evaluatorStructUrl = evaluatorUrl.appending("/Evaluator.swift")
        let evaluatorStructFile = EvaluatorBuilder().generateSyntax(with: phi)
        try FileHandler.write(evaluatorStructFile, to: evaluatorStructUrl)
        
        let extensionsUrl = evaluatorUrl.appending("/Extensions.swift")
        let extensionsFile = ExtensionsBuilder().generateSyntax()
        try FileHandler.write(extensionsFile, to: extensionsUrl)
        
        let resultsUrl = evaluatorUrl.appending("/ResultPrinter.swift")
        let resultsFile = ResultPrinterBuilder().generateSyntax(with: phi)
        try FileHandler.write(resultsFile, to: resultsUrl)
        
        let mainUrl = evaluatorUrl.appending("/ESQLEvaluator.swift")
        let mainFile = MainBuilder().generateSyntax()
        try FileHandler.write(mainFile, to: mainUrl)
    }
    
    /// Reads the parameters of `Phi` from a file path
    public static func constructPhi(from filePath: String) throws -> Phi {
        let contents = try FileHandler.read(from: filePath)
        let phi = try Phi(string: contents)
        return phi
    }
}
