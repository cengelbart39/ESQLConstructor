import Testing
@testable import ESQLConstructor

@Test func example() async throws {
    let fileUrl = "/Users/christopher/Developer/esql.txt"
    let fileContents = try FileHandler.read(from: fileUrl)
    let phi = try Phi(string: fileContents)
    let code = SyntaxBuilder().generateCode(with: phi)
    try FileHandler.write(code)
}

@Test func connectToDB() async {
    let service = PostgresService(host: "localhost", username: "postgres", password: "040839", database: nil)
    let status = await service.verify()
    #expect(status)
}
