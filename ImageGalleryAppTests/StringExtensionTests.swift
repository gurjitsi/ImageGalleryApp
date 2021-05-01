//
//  StringExtensionTests.swift
//  ImageGalleryAppTests
//
//  Created by Gurjit Singh on 01/05/21.
//

import XCTest
@testable import ImageGalleryApp

class StringExtensionTests: XCTestCase {

    func testRemoveSpaceFromString() {
        let string = "Flickr Image"
        XCTAssertEqual(string.removeSpaceFromString, "FlickrImage", "There was no space removed from the strings")
    }
}
