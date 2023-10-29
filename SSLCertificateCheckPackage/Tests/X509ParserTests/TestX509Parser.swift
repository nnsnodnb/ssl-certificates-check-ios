//
//  TestX509Parser.swift
//  
//
//  Created by Yuya Oka on 2023/10/27.
//

@testable import X509Parser
import XCTest

final class TestX509Parser: XCTestCase {
    func testParse() throws {
        let derURL = Bundle.module.url(forResource: "example-com", withExtension: "der")!
        let derData = try Data(contentsOf: derURL)
        _ = try X509Parser.parse(from: derData)
    }
}
