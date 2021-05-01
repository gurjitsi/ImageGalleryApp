//
//  FlickrCollectionViewController.swift
//  ImageGalleryApp
//
//  Created by Gurjit Singh on 28/04/21.
//

import UIKit

class FlickrCollectionViewController: UICollectionViewController {

    var imageData = [FlickrUrls]()
    let constants = Constants()
    let fetchImages = FetchFlickrImages()
    var tags = "kitten"
    var pageCount = 1
    var urlImages = [String]()
    let imageSource = FlickrImageSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flickr Image App"
        fetchFlickrImages(tags: tags, pageCount: pageCount)
    }

    //Mark:- Clearing old data to feed new data
    
    func resetImagesData() {
        imageData.removeAll()
        urlImages.removeAll()
        tags = ""
        pageCount = 1
        collectionView.reloadData()
    }

    func fetchFlickrImages(tags: String, pageCount: Int) {
        //pageCount += 1
        fetchImages.fetchImageDataFromFlickr(tags, pageCount) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success((let photoInfo, let sizeInfo)):
                    self?.imageData.append(contentsOf: photoInfo.photos?.photo ?? [])
                    self?.urlImages = sizeInfo
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urlImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = urlImages[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: constants.reuseIdentifier, for: indexPath) as! FlickrCollectionViewCell
        guard urlImages.count != 0 else {
            return cell
        }
        guard let url = URL(string: data) else {
            return cell
        }
        let image = imageSource.cache.object(forKey: url as NSURL)
        cell.imageFlickr.backgroundColor = UIColor(white: 0.95, alpha: 1)
        cell.imageFlickr.image = image
        if image == nil {
            imageSource.getImagesFromURL(from: url) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        let indexPath = collectionView.indexPath(for: cell)
                        if indexPath == indexPath {
                            cell.imageFlickr.image = image
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        return cell
    }
}

//Mark:- UISearchBarDelegate

extension FlickrCollectionViewController: UISearchBarDelegate {

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let searchBarView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: constants.reuseIdentifierSearch, for: indexPath)
        return searchBarView
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        resetImagesData()
        //check if search bar text is empty
        guard !(searchBar.text?.isEmpty ?? true) else {
            return
        }
        fetchFlickrImages(tags: searchBar.text ?? "", pageCount: pageCount)
        searchBar.text = ""
    }
}

//Mark:- UICollectionViewDelegateFlowLayout

extension FlickrCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = constants.sectionInsets.left * (constants.itemsPerRow + 1)
        let width = view.frame.width - padding
        let widthPerImage = width / constants.itemsPerRow
        return CGSize(width: widthPerImage, height: widthPerImage)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return constants.sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return constants.sectionInsets.left
    }
}
