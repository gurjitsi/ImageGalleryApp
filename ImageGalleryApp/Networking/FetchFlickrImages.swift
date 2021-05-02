//
//  FetchFlickrImages.swift
//  ImageGalleryApp
//
//  Created by Gurjit Singh on 28/04/21.
//

import Foundation

class FetchFlickrImages {

    let constants = Constants()
    let jsonDecoder = JSONDecoder()

    //Mark:- Get images from flickr

    func fetchImageDataFromFlickr(_ keywords: String, _ pageCount: Int, completion: @escaping (Result<FlickrImage, Error>) -> Void) {
        let searchKeywords = keywords.removeSpaceFromString
        guard let urlPath = getURLPath(searchKeywords, pageCount) else { return }
        let dataTask = URLSession.shared.dataTask(with: urlPath) { (data, response, error) in
            if let data = data {
                do {
                    let photosInfo = try self.jsonDecoder.decode(FlickrImage.self, from: data)
                    completion(.success(photosInfo))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
}

//Mark: - Get image size information

extension FetchFlickrImages {
    func fetchImageSize(_ id: String, completion: @escaping (Result<FlickrImageSize, Error>) -> Void) {
        guard let urlPath = getSizeURLPath(id) else { return }
        let dataTaskSize = URLSession.shared.dataTask(with: urlPath) { (dataSize, response, error) in
            if let dataSize = dataSize {
                do {
                    let photosSize = try self.jsonDecoder.decode(FlickrImageSize.self, from: dataSize)
                    completion(.success(photosSize))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        dataTaskSize.resume()
    }
}

//Mark:- URL for images and sizes

extension FetchFlickrImages {

    func getURLPath(_ tags: String, _ pageCount: Int) -> URL? {
        guard let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(constants.flickrKey)&tags=\(tags)&page=\(pageCount)&format=json&nojsoncallback=1") else {
            return nil
        }
        return url
    }

    func getSizeURLPath(_ id: String) -> URL? {
        guard let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=f9cc014fa76b098f9e82f1c288379ea1&photo_id=\(id)&format=json&nojsoncallback=1") else {
            return nil
        }
        return url
    }
}
