//
//  iOSTests
//  EasyStash-iOS
//
//  Created by khoa on 27/05/2019.
//  Copyright © 2019 Khoa Pham. All rights reserved.
//

import XCTest
import EasyStash

class iOSTests: XCTestCase {

    var storage: Storage!

    override func setUp() {
        super.setUp()

        let options = Options()
        storage = try! Storage(options: options)
    }

    override func tearDown() {
        super.tearDown()

        try? storage.removeAll()
    }

    func testObject() {
        let users = [
            User(city: "Oslo", name: "A"),
            User(city: "Berlin", name: "B"),
            User(city: "New York", name: "C")
        ]

        do {
            try storage.save(object: users, key: "users")
            storage.cache.removeAllObjects()
            let loadedUsers = try storage.load(key: "users", as: [User].self)
            XCTAssertEqual(users, loadedUsers)

            try storage.remove(key: "users")
            XCTAssertFalse(storage.exists(key: "users"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testImage() {
        let image = UIColor.red.image(CGSize(width: 100, height: 100))

        do {
            try storage.save(object: image, key: "image")
            storage.cache.removeAllObjects()
            let loadedImage = try storage.load(key: "image")
            XCTAssertEqual(
                loadedImage.size.mutiply(loadedImage.scale),
                image.size.mutiply(image.scale)
            )

            try storage.remove(key: "image")
            XCTAssertFalse(storage.exists(key: "image"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testPrimitive() {
        do {
            try storage.save(object: 1, key: "number")
            try storage.save(object: "Hello", key: "string")

            let number = try storage.load(key: "number", as: Int.self)
            let string = try storage.load(key: "string", as: String.self)

            XCTAssertEqual(number, 1)
            XCTAssertEqual(string, "Hello")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testFolderSize() {
        let image = UIColor.red.image(CGSize(width: 100, height: 100))

        do {
            try storage.save(object: image, key: "image")
            XCTAssertEqual(try storage.folderSize(), 2425)
            XCTAssertEqual(try storage.isEmpty(), false)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testFiles() {
        do {
            try storage.save(object: 1, key: "one")
            try storage.save(object: 2, key: "two")
            try storage.save(object: 3, key: "three")

            let files = try storage
                .files()
                .sorted(by: { $0.modificationDate! < $1.modificationDate! })

            XCTAssertEqual(files.count, 3)
            XCTAssertEqual(files[0].name, "one")
            XCTAssertEqual(files[1].name, "two")
            XCTAssertEqual(files[2].name, "three")
            XCTAssertEqual(files[0].size, 12)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testRemoveAll() {
        do {
            try storage.save(object: 1, key: "one")
            try storage.save(object: 2, key: "two")
            try storage.save(object: 3, key: "three")

            try storage.removeAll()

            XCTAssertFalse(storage.exists(key: "one"))
            XCTAssertFalse(storage.exists(key: "two"))
            XCTAssertFalse(storage.exists(key: "three"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testPerformanceUsingEncoder() {
        let users = Array(0..<10_000).map { _ in User2(city: "Oslo", name: "A") }
        measure {
            let encoder = JSONEncoder()
            let _ = try! encoder.encode(users)
        }
    }

    func testPerformanceUsingKeyArchiver() {
        let users = Array(0..<10_000).map { _ in User3(city: "Oslo", name: "A") }
        measure {
            NSKeyedArchiver.archivedData(withRootObject: users)
        }
    }
}

extension CGSize {
    func mutiply(_ value: CGFloat) -> CGSize {
        return CGSize(width: width * value, height: height * value)
    }
}
