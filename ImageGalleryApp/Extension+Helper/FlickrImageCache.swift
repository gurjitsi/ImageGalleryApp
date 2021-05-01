//
//  FlickrImageCache.swift
//  ImageGalleryApp
//
//  Created by Gurjit Singh on 30/04/21.
//

import Foundation

class FlickrImageCache {
    func clearContents(_ url:URL) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)
            let urls = contents.map { URL(string:"\(url.appendingPathComponent("\($0)"))")! }
            urls.forEach {  try? FileManager.default.removeItem(at: $0) }
            _ = try FileManager.default.contentsOfDirectory(atPath: url.path)
        }
        catch {
            print(error)

        }
     }
}
