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
    
        guard let info = IdentityInfo(
            privateKey: privateKey,
            name: "Alice",
            channels: [
                IdentityChannel(name: "twitter", value: "@alice"),
                IdentityChannel(name: "facebook", value: "NotRealAlice"),
            ]
        ) else {
            XCTFail()
            return
        }
        
        let supplementation = IdentitySupplementation(
            name: "Alice or not Alice?",
            channels: [
                IdentityChannel(name: "discord", value: "Alice#1234"),
            ]
        )
        
        let card = Bizcard(info: info, supplementation: supplementation)
        let serialized = try card.serialize()
        let validateResult = card.validate()
        do {
            try validateResult.get()
        } catch {
            XCTFail()
        }
        
        let cards = try Bizcard.deserialize(text: serialized)
        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards.first, card)
        
        print("*** ID card ***")
        print(card)
        print("*** serialized ID card ***")
        print(serialized)
    }
    
    func testIdentityCardSerialization_tampered_modify_armor() {
        let tampered = serializedSampleCard.replacingOccurrences(of: "DK6T9g", with: "DK6T9g".lowercased())
        
        var deserializeError: Error?
        do {
            _ = try Bizcard.deserialize(text: tampered)
        } catch {
            // should catch error here
            deserializeError = error
        }
        
        XCTAssertNotNil(deserializeError)
        print(deserializeError!.localizedDescription)
    }
    
    func testIdentityCardSerialization_tampered_modify_info() {
        let tampered = serializedSampleCard_PropertyTamperAttact
        var deserializeError: Error?
        let cards = (try? Bizcard.deserialize(text: tampered)) ?? []
        XCTAssertEqual(cards.count, 1)
        
        do {
            try cards[0].validate().get()
        } catch {
            // should catch error here
            deserializeError = error
        }

        XCTAssertNotNil(deserializeError)
        print(deserializeError!)
    }
    
    var serializedSampleCard: String { "IdCardBeginIINrp5PxsVUn8KJHG45Ns8W2KVAaM3FDRjHHxdJ45kCtpy94NcJVHoKZV94nsZDJMaXM8j5shhtCW2sHJCyBXziDCVUWBvf3mvh3ELJQufqVvDUCK9BgMLD7HmUHvAHitW29KbHJAhNWFrjt6Hv4EHC9XfGf6PvKfan25uzJbVp7G2HMtQLKZHVrCttZCP4eUGqGiUeXXuE9H225F65J8kkKB4QQYdHJSDaPzD8WqZqDbS4A83muQZSVogiQzqyZeq21vQpYkA2TZQwi3189ZQypAZ8zv6puaVxiwdVScpLft3bRdyop1b4Rv257G2uTWLeJjS9d775JLXKt2LL2A9dAEHKPbJQxAD9ETM6bjdbCkAbQZRVvR6bh27CU7dkbFZXhDZCojLodJsFGmgRwE6o1NiXKFVcHGm4hWWgZitEDcaiJxt1ToEZE7pLDBEwLWV7eQKUYxmgtYiu2HyKE5V8Yh3RM9SYyCcnNkpKya1y7YK6UK94gicGVYqRBHHnmK862UB4LwHXEMV56WDK6T9gXfP79zAeCkZnzsNFaK8jHTPE1je8KUKdtt4hohDKTq8crjnHH2LUkrsePms9uLdu7x5PTgvvHyn5kprq4oZJ8DfXYgjfPxUgCBWiHqXb3KeFLKMC48WwJdQ6f9bBmCHE7PcB1CytbjJWNPxGrqFqv2Kpr8IIEndIdCard"
    }
    
    // name: "Alice" -> "Alicee"
    var serializedSampleCard_PropertyTamperAttact: String {
        "IdCardBeginIINrp5PxsVUn8KJHG45Ns8W2KVAaM3FDRjHHxdJ45kCtpy94NcJVHoKZV94nsZfM4xcM8jAHAfeXfDaAST7fkiHU2CUBF21ZGPDUzYj1mckwarjnfFt96i8JmUhKTyv52Xv7QZHJ8dhzqEDA8HdFtSFXTE75KTq8crjgtWWHdeYgThJ3a4J1cvzuHPAAbKeAWUWo7eNUK8jHTLYisS5J8kkKB7QjFNLUBt5A8zfiP9PtXGHJ7sBfF5jVEZS7y7yA4crrWzGk3eHHoXb1TEfan1hRCvrChB3pZ8pYJQEXmYkC4uuCyscWQKJVLLkHsFS2YJ18Mkb3eFC8VLtM6pctfZNL8oMr6NCtjNJpnnX4D7DpZhYZ7EfG6ZVJBEMe7QLwQUHQ3y6xiLCQ57gtnKE78R8rnXojL373dgz9b6n7M5EUBG2csFSg87DoyqKT7GXcCZ6sBMUX7HEEdRkBYmCr88mw13WKUKdtt4hohDKTq8crjnHH2LUkrsePms9uLdu7x5PTgvvHyn5kprq4oZJ8DfXYgjfPxUgCBWiHqXb3KeFLKMC48WwJdQ6fwagP7HJdQ3YrkFdh2L96DTnTbQWQHRbcsdqBsZAJTjBc7FNoi7KyPcRssro7UJy73RWXdsfbLJnvrQtF6JgASm3UViae2LKUASZnmgYZcKU6bUBAiK452MtDCtIIEndIdCard"
    }
    
}
