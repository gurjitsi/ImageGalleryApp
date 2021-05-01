//
//  ImageSource.swift
//  ImageGalleryApp
//
//  Created by Gurjit Singh on 28/04/21.
//

import Foundation
import UIKit

protocol FetchImages {}

extension FetchImages where Self == FlickrImageSource {
    func fetchImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        self.getImagesFromURL(from: url, completion: completion)
    }
}

class FlickrImageSource: FetchImages {

    var cache = NSCache<NSURL, UIImage>()

    //Mark:- Returns cached image or loads and cache it
    func getImagesFromURL(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {

        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            if let image = self.cache.object(forKey: url as NSURL) {
                DispatchQueue.main.async {
                    completion(.success(image))
                }
                return
            }

            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.cache.setObject(image, forKey: url as NSURL)
                        completion(.success(image))
                    }
                }
            } catch {
                print(error)
            }
        })
    }
}

