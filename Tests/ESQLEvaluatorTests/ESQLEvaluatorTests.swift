import Testing
@testable import ESQLEvaluator

@Test func example() async throws {
    let fileUrl = "/Users/christopher/Developer/esql.txt"
    let fileContents = try FileHandler.read(fileUrl)
    let phi = try Phi(string: fileContents)
    let code = SyntaxBuilder().generateCode(with: phi)
    print(code)
}
