//
//  FlickrImage.swift
//  ImageGalleryApp
//
//  Created by Gurjit Singh on 28/04/21.
//

import Foundation
import UIKit

struct FlickrImage: Codable {
    let photos: FlickrPageResult?
}

struct FlickrPageResult: Codable {
    let photo: [FlickrUrls]
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
}

struct FlickrUrls: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
}
