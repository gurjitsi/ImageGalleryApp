//
//  CollectionViewModel.swift
//  ImageGalleryApp
//
//  Created by Gurjit Singh on 02/05/21.
//

import Foundation
import UIKit

class CollectionViewModel {
    let constants = Constants()
    var pageCount = 0
    var tags = "kitten"
    var imageData = [FlickrUrls]()
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    let fetchImages = FetchFlickrImages()
    let imageSource = FlickrImageSource()
}

extension CollectionViewModel {
    
    func numberOfRows(frameWidth: CGFloat) -> CGSize {
        let padding = constants.sectionInsets.left * (constants.itemsPerRow + 1)
        let width = frameWidth - padding
        let widthPerImage = width / constants.itemsPerRow
        return CGSize(width: widthPerImage, height: widthPerImage)
    }
    
    var resetImagesData : Void {
        imageData.removeAll()
        tags = ""
        pageCount = 0
    }
}
