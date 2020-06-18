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
 
    func testCoreDataStackReset() {
        coreDataStack.reset()
    }
    
}

extension CoreDataStackTests {
    
    func testCURDForContact() {
        coreDataStack.reset()

        // init keypair
        let Ed25519Keypair = Ed25519.Keypair()
        let Ed25519PrivateKey = Ed25519Keypair.privateKey
        let Ed25519PublicKey = Ed25519Keypair.publicKey

        // insert keypair
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
            XCTAssertEqual(contact.i18nNames["en"], "Alice")
            XCTAssertEqual(contact.i18nNames["jp"], "アリス")
            XCTAssertNotNil(contact.keypair)
            XCTAssertEqual(contact.channels.count, 2)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
}

extension CoreDataStack {
    
    static let testable: CoreDataStack = {
        let storeURL = URL.storeURL(for: "group.im.dimension.Mailway", databaseName: "CoreDataStack-Testable")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        return CoreDataStack(persistentStoreDescriptions: [storeDescription])
    }()
    
    func reset() {
        let stores = persistentContainer.persistentStoreCoordinator.persistentStores
        
        for store in stores {
            let storeURL = store.url!
            
            do {
                try persistentContainer.persistentStoreCoordinator.remove(store)
                try FileManager.default.removeItem(at: storeURL)
                try persistentContainer.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                os_log("%{public}s[%{public}ld], %{public}s: did reset database", ((#file as NSString).lastPathComponent), #line, #function)

            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
}
