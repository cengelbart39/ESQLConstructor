// Christopher Engelbart
// CWID: 10467610

import Testing
import Foundation
@testable import ESQLConstructor

@Test func example() async throws {
    let fileUrl = "/Users/christopher/Developer/esql.txt"
    let fileContents = try FileHandler.read(from: fileUrl)
    let phi = try Phi(string: fileContents)
    let code = MainBuilder().generateSyntax()
    print(code)
    try FileHandler.write(code, to: "/Users/christopher/Developer/output.swift")
}

@Test func connectToDB() async {
    let service = PostgresService(host: "localhost", username: "postgres", password: "040839", database: nil)
    let status = await service.verify()
    #expect(status)
}

@Test func writeOutputStructure() throws {
    let phi = try FileHandler.constructPhi(from: "/Users/christopher/Developer/esql.txt")
    let service = PostgresService(host: "localhost", username: "postgres", password: "040839")
    try FileHandler.createOutputFiles(at: "/Users/christopher/Developer", with: phi, using: service)
}
