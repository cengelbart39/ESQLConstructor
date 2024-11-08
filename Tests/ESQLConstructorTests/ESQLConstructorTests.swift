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

//@Test func parse() throws {
//    let tokens = ["sum_1_quant", ">", "2", "*", "sum_2_quant", "or", "avg_1_quant", ">", "avg_3_quant"]
//    let parser = PredicateParser(tokens: tokens)
//    let output = try parser.parse()
//    print(output)
//}
//
//@Test func parseParen() throws {
//    let tokens = "(sum_1_quant = 1 and (sum_2_quant < 2 or avg_1_quant = 3)) or not (avg_3_quant > 4)"
//    
//    let regex = try NSRegularExpression(pattern: "\\w+|\\(\\)|==|!=|<=|>=|\\=|\\<|\\>|\\+|\\-|[[:punct:]]")
//    let results = regex
//        .matches(in: tokens, range: NSRange(location: 0, length: tokens.count))
//        .map({ String(tokens[Range($0.range, in: tokens)!]) })
//    
//    let parser = PredicateParser(tokens: results)
//    let output = try parser.parse()
//    print(output)
//}
