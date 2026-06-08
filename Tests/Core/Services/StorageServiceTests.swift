import XCTest
@testable import TestProject

final class StorageServiceTests: XCTestCase {
    var storageService: StorageService!

    override func setUp() {
        super.setUp()
        storageService = StorageService()
    }
}

