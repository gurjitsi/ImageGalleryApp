//
//  FlickrSoleImage.swift
//  ImageGalleryApp
//
//  Created by Gurjit Singh on 29/04/21.
//

import Foundation

struct FlickrImageSize: Codable {
    let sizes: FlickrSize?
}

struct FlickrSize: Codable {
    let size: [FlickrImageUrls]
}

struct FlickrImageUrls: Codable {
    let label: String
    let source: String
    let url: String
    let media: String
}
