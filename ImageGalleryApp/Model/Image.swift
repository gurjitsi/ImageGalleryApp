//
//  Image.swift
//  ImageGalleryApp
//
//  Created by Gurjit Singh on 28/04/21.
//

import Foundation
import UIKit

struct Image: Codable{
    let imageData: Data?

    init(withImage image: UIImage) {
        self.imageData = image.pngData()
    }

    func getImage() -> UIImage? {
        guard let imageData = self.imageData else {
            return nil
        }
        let image = UIImage(data: imageData)

        return image
    }
}
