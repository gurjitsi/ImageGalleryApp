//
//  String+Extensions.swift
//  ImageGalleryApp
//
//  Created by Gurjit Singh on 29/04/21.
//

import Foundation

extension String {
    var removeSpaceFromString: String {
        return self.components(separatedBy: .whitespaces).joined()
    }
}
