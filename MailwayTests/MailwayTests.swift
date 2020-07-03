//
//  MailwayTests.swift
//  MailwayTests
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import XCTest
@testable import Mailway
import NtgeCore
import MessagePack

class MailwayTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension MailwayTests {
    
    func testSmoke() { }
    
    func testIdentityCardSerialization() throws {
        let keypair = Ed25519.Keypair()
        let privateKey = keypair.privateKey
    
        let info = IdentityInfo(
            privateKey: privateKey,
            name: "Alice",
            i18nNames: [:],
            channels: []
        )
        
        let supplementation = IdentitySupplementation(
            name: "Alice or not Alice ",
            i18nNames: [:],
            channels: []
        )
        
        let card = IdentityCard(info: info, supplementation: supplementation)
        
        let encoder = MessagePackEncoder()
        let encoded = try encoder.encode(card)
        
        let decoder = MessagePackDecoder()
        let decoded = try decoder.decode(IdentityCard.self, from: encoded)
        
        XCTAssertEqual(card, decoded)
        print(decoded)
    }
    
}
