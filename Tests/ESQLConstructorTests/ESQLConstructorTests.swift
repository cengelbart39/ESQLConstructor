import Testing
@testable import ESQLConstructor

@Test func example() async throws {
    let fileUrl = "/Users/christopher/Developer/esql.txt"
    let fileContents = try FileHandler.read(from: fileUrl)
    let phi = try Phi(string: fileContents)
    let code = SyntaxBuilder.MFStruct().generateSyntax(with: phi)
    print(code)
    try FileHandler.write(code, to: "/Users/christopher/Developer/output.swift")
}

@Test func connectToDB() async {
    let service = PostgresService(host: "localhost", username: "postgres", password: "040839", database: nil)
    let status = await service.verify()
    #expect(status)
}

//@Test func writeOutputStructure() throws {
//    try FileHandler.createOutputFiles()
//}
