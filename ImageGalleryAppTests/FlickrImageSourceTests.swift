//
//  FlickrImageSourceTests.swift
//  ImageGalleryAppTests
//
//  Created by Gurjit Singh on 01/05/21.
//

import XCTest
@testable import ImageGalleryApp

class FlickrImageSourceTests: XCTestCase {

    var imageSource: FlickrImageSource!

    override func setUpWithError() throws {
        imageSource = FlickrImageSource()
    }

    override func tearDownWithError() throws {
        imageSource = nil
        try super.tearDownWithError()
    }

    func testGetImageWithEmptyURL() {
        guard let url = URL(string: "") else { return }
        imageSource.getImagesFromURL(from: url) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure:
                    XCTAssert(false, "Images with an empty URL are not retrievable.")
                default:
                    break
                }
            }
        }
    }

}
