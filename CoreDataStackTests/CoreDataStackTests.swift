//
//  CoreDataStackTests.swift
//  CoreDataStackTests
//
//  Created by Cirno MainasuK on 2020-6-11.
//  Copyright © 2020 Dimension. All rights reserved.
//

import XCTest
import CoreData
@testable import CoreDataStack

class CoreDataStackTests: XCTestCase {
    
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        context = CoreDataStack.shared.persistentContainer.viewContext
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
