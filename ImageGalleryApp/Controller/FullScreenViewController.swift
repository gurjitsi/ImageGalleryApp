//
//  DetailViewController.swift
//  ImageGalleryApp
//
//  Created by Gurjit Singh on 02/05/21.
//

import UIKit

class FullScreenViewController: UIViewController {

    @IBOutlet weak var largeImage: UIImageView!
    var photoID = ""
    let fetchImages = FetchFlickrImages()
    let imageSource = FlickrImageSource()
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLargeImage()
    }
}

//Mark:- Fetch Large Image

extension FullScreenViewController {
    func fetchLargeImage() {
        fetchImages.fetchImageSize (photoID) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let urlInfo):
                    let sourceImage = urlInfo.sizes?.size[9].source
                    guard let urlPath = sourceImage else { return }
                    let image = self.imageSource.cache.object(forKey: URL(string: urlPath)! as NSURL)
                    self.largeImage.backgroundColor = UIColor(white: 0.95, alpha: 1)
                    self.largeImage.image = image
                    if image == nil {
                        guard let url = URL(string: urlPath) else { return }
                        self.imageSource.getImagesFromURL(from: url) { (result) in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let image):
                                    self.loadingIndicator.isHidden = true
                                    self.largeImage.image = image
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
