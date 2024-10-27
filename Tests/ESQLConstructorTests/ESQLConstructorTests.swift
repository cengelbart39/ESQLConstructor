import Testing
import Foundation
@testable import ESQLConstructor

@Test func example() async throws {
    let fileUrl = "/Users/christopher/Developer/esql.txt"
    let fileContents = try FileHandler.read(from: fileUrl)
    let phi = try Phi(string: fileContents)
    let code = MFStructBuilder().generateSyntax(with: phi)
    print(code)
    try FileHandler.write(code, to: "/Users/christopher/Developer/output.swift")
}

@Test func connectToDB() async {
    let service = PostgresService(host: "localhost", username: "postgres", password: "040839", database: nil)
    let status = await service.verify()
    #expect(status)
}

@Test func writeOutputStructure() throws {
    let service = PostgresService(host: "localhost", username: "postgres", password: "040839")
    let code = PostgresServiceBuilder().generateSyntax(with: service)
    print(code)
}

@Test func salesDecoding() async throws {
    let service = PostgresService(host: "localhost", username: "postgres", password: "040839")
    
    try await service.connectAndRun {
        let rows = try await service.query("select * from sales", until: 15)
        
        for try await row in rows.decode((String, String, Int, Int, Int, String, Int, Date).self) {
            let sale = Sales(row)
            print(sale)
        }
    }
}

struct MFStruct {
    let cust: String
    let count_1_quant: Double
    let sum_2_quant: Double
    let max_3_quant: Double
}

extension Array where Element == MFStruct {
    func exists(cust: String) -> Bool {
        return self.filter({ $0.cust == cust }).count == 1
    }
}

@Test func populateMFStruct() async throws {
    var mfStructs = [MFStruct]()
    let service = PostgresService(host: "localhost", username: "postgres", password: "040839")
    
    try await service.connectAndRun {
        let rows = try await service.query("select * from sales", until: 15)
        
        for try await row in rows.decode(SalesSchema.self) {
            if !mfStructs.exists(cust: row.0) {
                let mfStruct = MFStruct(
                    cust: row.0,
                    count_1_quant: .zero,
                    sum_2_quant: .zero,
                    max_3_quant: Double(Int.min)
                )
                
                mfStructs.append(mfStruct)
            }
        }
    }
    
    print(mfStructs)
}
