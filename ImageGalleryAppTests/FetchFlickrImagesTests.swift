//
//  ImageGalleryAppTests.swift
//  ImageGalleryAppTests
//
//  Created by Gurjit Singh on 28/04/21.
//

import XCTest
@testable import ImageGalleryApp

class FetchFlickrImagesTests: XCTestCase {

    var fetchImages: FetchFlickrImages!

    override func setUpWithError() throws {
        fetchImages = FetchFlickrImages()
    }

    override func tearDownWithError() throws {
        fetchImages = nil
        try super.tearDownWithError()
    }

    func testFetchImagesWithEmptyTag() throws {
        let tag = ""
        fetchImages.fetchImageDataFromFlickr(tag, 1) { (result) in
                switch result {
                case .failure:
                    XCTAssert(false, "Images with an empty tag are not retrievable.")
                default:
                    break
                }
        }
    }

    func testSearchImagesWithSpecialTag() throws {
        let tag = "Doc-123 A/456 model 789"
        fetchImages.fetchImageDataFromFlickr(tag, 1) { (result) in
                switch result {
                case .success:
                    XCTAssert(false, "When the data is incorrect, failure is expected.")
                default:
                    break
                }
        }
    }

    func testFetchImageSizeWithEmptyData() throws {
        let data = [FlickrUrls]()
        fetchImages.fetchImageSize(data) { (sizeResult) in
                switch sizeResult {
                case .success:
                    XCTAssert(false, "When there is no data, expect failure.")
                default:
                    break
                }
        }
    }

}
