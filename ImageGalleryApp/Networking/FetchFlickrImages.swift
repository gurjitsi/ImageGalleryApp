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
    var isTaskCompleted = false
    var taskCount = 1
    var imageSource = [String]()

    //Mark:- Get images from flickr

    func fetchImageDataFromFlickr(_ keywords: String, _ pageCount: Int, completion: @escaping (Result<(FlickrImage, [String]), Error>) -> Void) {
        let searchKeywords = keywords.removeSpaceFromString
        guard let urlPath = getURLPath(searchKeywords, pageCount) else { return }
        let dataTask = URLSession.shared.dataTask(with: urlPath) { (data, response, error) in
            if let data = data {
                do {
                    let photosInfo = try self.jsonDecoder.decode(FlickrImage.self, from: data)
                    self.fetchImageSize(photosInfo.photos?.photo ?? []) { (sizeResult) in
                        DispatchQueue.main.async {
                            switch sizeResult {
                            case .success( _):
                                self.taskCount += 1
                                if self.taskCount == photosInfo.photos?.photo.count {
                                    self.isTaskCompleted = true
                                }

                                if self.isTaskCompleted {
                                    completion(.success((photosInfo, self.imageSource)))
                                    self.isTaskCompleted = false
                                    self.taskCount = 1
                                    self.imageSource.removeAll()
                                }
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
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

//Mark: - Get image size

extension FetchFlickrImages {

    func fetchImageSize(_ imageResult: [FlickrUrls], completion: @escaping (Result<FlickrImageSize, Error>) -> Void) {
        if imageResult.count != 0 {
            for photoID in imageResult {
                guard let urlPathSize = getSizeURLPath(photoID.id) else { return }
                let dataTask = URLSession.shared.dataTask(with: urlPathSize) { (data, response, error) in
                    if let data = data {
                        do {
                            let photosSize = try self.jsonDecoder.decode(FlickrImageSize.self, from: data)
                            guard let photoSizeCount = photosSize.sizes?.size.count else { return }
                            for item in 0..<photoSizeCount {
                                if photosSize.sizes?.size[item].label == "Large Square" {
                                    self.imageSource.append(photosSize.sizes?.size[item].source ?? "")
                                }
                            }
                            completion(.success(photosSize))
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
