//
//  CoreDataStackTests.swift
//  CoreDataStackTests
//
//  Created by Cirno MainasuK on 2020-6-11.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import XCTest
import Combine
import CoreData
@testable import CoreDataStack
import NtgeCore

class CoreDataStackTests: XCTestCase {
    
    var disposeBag = Set<AnyCancellable>()
    
    let coreDataStack = CoreDataStack.testable
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        context = coreDataStack.persistentContainer.viewContext
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


extension CoreDataStackTests {
    
    func testCURDForContact() {
        // init keypair
        let Ed25519Keypair = Ed25519.Keypair()
        let Ed25519PrivateKey = Ed25519Keypair.privateKey
        let Ed25519PublicKey = Ed25519Keypair.publicKey

        // insert keypair & contact & contact channels
        let insertExpectation = expectation(description: "insert keypair")
        context.performChanges {
            let keypairProperty: Keypair.Property = {
                return Keypair.Property(privateKey: Ed25519PrivateKey.serialize(), publicKey: Ed25519PublicKey.serialize(), keyID: Ed25519PublicKey.keyID)
            }()
            let keypair = Keypair.insert(into: self.context, property: keypairProperty)
            
            let emailChannel = ContactChannel.insert(into: self.context,
                                                     property: ContactChannel.Property(name: .email, value: "alice@gmail.com"))
            let twitterChannel = ContactChannel.insert(into: self.context,
                                                     property: ContactChannel.Property(name: .twitter, value: "@alice"))
            let contactProperty = Contact.Property(name: "Alice", i18nNames: ["en":"Alice", "jp": "アリス"])
            Contact.insert(into: self.context, property: contactProperty, keypair: keypair, channels: [emailChannel, twitterChannel])
        }
        .sink { result in
            do {
                let _ = try result.get()
                insertExpectation.fulfill()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        .store(in: &disposeBag)
        wait(for: [insertExpectation], timeout: 5.0)
        
        // check keypair
        do {
            let keypairs = try context.fetch(Keypair.sortedFetchRequest)
            XCTAssertEqual(keypairs.count, 1)

            guard let keypair = keypairs.first else {
                XCTFail()
                return
            }
            XCTAssertEqual(keypair.privateKey, Ed25519PrivateKey.serialize())
            XCTAssertEqual(keypair.publicKey, Ed25519PublicKey.serialize())
            XCTAssertEqual(keypair.keyID, Ed25519PublicKey.keyID)
            XCTAssertNotNil(keypair.contact)

        } catch {
            XCTFail(error.localizedDescription)
        }
        
        // check contact
        do {
            let contacts = try context.fetch(Contact.sortedFetchRequest)
            XCTAssertEqual(contacts.count, 1)
            
            guard let contact = contacts.first else {
                XCTFail()
                return
            }
            XCTAssertEqual(contact.name, "Alice")
            XCTAssertEqual(contact.i18nNames?["en"], "Alice")
            XCTAssertEqual(contact.i18nNames?["jp"], "アリス")
            XCTAssertNotNil(contact.keypair)
            XCTAssertEqual(contact.channels?.count, 2)
            let emailChannels = contact.channels?.filter { (channel) -> Bool in
                return channel.name == ContactChannel.Property.ChannelName.email.text && channel.value == "alice@gmail.com"
            }
            let twitterChannels = contact.channels?.filter { (channel) -> Bool in
                return channel.name == ContactChannel.Property.ChannelName.twitter.text && channel.value == "@alice"
            }
            XCTAssertEqual(emailChannels?.count, 1)
            XCTAssertEqual(twitterChannels?.count, 1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testCURDForChatMessage() throws {
        let alice = try setupStubAlice()
        let bob = try setupStubBob()
        
        let insertExpectation = expectation(description: "insert chat message")
        context.performChanges {
            
        }
        .sink { result in
            do {
                let _ = try result.get()
                insertExpectation.fulfill()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        .store(in: &disposeBag)
        wait(for: [insertExpectation], timeout: 5.0)

    }
    
}

extension CoreDataStackTests {
    
    // setup Alice identity
    func setupStubAlice() throws -> Contact {
        // insert identity
        let insertExpectation = expectation(description: "insert alice")
        context.performChanges {
            let keypair: Keypair = {
                let keypair = Ed25519.Keypair()
                let property = Keypair.Property(privateKey: keypair.privateKey.serialize(),
                                                publicKey: keypair.publicKey.serialize(),
                                                keyID: keypair.publicKey.keyID)
                return Keypair.insert(into: self.context, property: property)
            }()
            _ = Contact.insert(into: self.context,
                                       property: Contact.Property(name: "Alice"),
                                       keypair: keypair, channels: [])
        }
        .sink { result in
            do {
                let _ = try result.get()
                insertExpectation.fulfill()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        .store(in: &disposeBag)
        wait(for: [insertExpectation], timeout: 5.0)
        
        // check identity
        let identityFetchRequest = Contact.sortedFetchRequest
        identityFetchRequest.predicate = Contact.isIdentityPredicate
        let identities = try context.fetch(identityFetchRequest)
        XCTAssertEqual(identities.count, 1)
        let alice = identities.first
        XCTAssertNotNil(alice)
        XCTAssertEqual(alice?.name, "Alice")
        
        return alice!
    }
    
    // setup Bob contact
    func setupStubBob() throws -> Contact {
        // insert contact
        let insertExpectation = expectation(description: "insert Bob")
        context.performChanges {
            let keypair: Keypair = {
                let keypair = Ed25519.Keypair()
                let property = Keypair.Property(privateKey: nil,
                                                publicKey: keypair.publicKey.serialize(),
                                                keyID: keypair.publicKey.keyID)
                return Keypair.insert(into: self.context, property: property)
            }()
            _ = Contact.insert(into: self.context,
                               property: Contact.Property(name: "Bob"),
                               keypair: keypair, channels: [])
        }
        .sink { result in
            do {
                let _ = try result.get()
                insertExpectation.fulfill()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        .store(in: &disposeBag)
        wait(for: [insertExpectation], timeout: 5.0)
        
        // check contact
        let identityFetchRequest = Contact.sortedFetchRequest
        identityFetchRequest.predicate = Contact.notIdentityPredicate
        let identities = try context.fetch(identityFetchRequest)
        XCTAssertEqual(identities.count, 1)
        let bob = identities.first
        XCTAssertNotNil(bob)
        XCTAssertEqual(bob?.name, "Bob")
        
        return bob!
    }
    
}

extension CoreDataStack {
    
    static let testable: CoreDataStack = {
        let storeDescription = NSPersistentStoreDescription()
        
        // Use in-memory store for test
        storeDescription.type = NSInMemoryStoreType
        return CoreDataStack(persistentStoreDescriptions: [storeDescription])
    }()
    
    
}
