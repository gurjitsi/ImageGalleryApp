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
    var pageCount = 0
    let imageSource = FlickrImageSource()
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    let jsonDecoder = JSONDecoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flickr Image App"
        self.view.addSubview(loadingIndicator)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = self.view.center
        fetchFlickrImages(tags: tags)
    }

    //Mark:- Clearing old data to feed new data
    
    func resetImagesData() {
        imageData.removeAll()
        tags = ""
        pageCount = 0
        self.collectionView.reloadData()
    }

    func fetchFlickrImages(tags: String) {
        self.pageCount += 1
        loadingIndicator.startAnimating()
        fetchImages.fetchImageDataFromFlickr(tags, pageCount) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let photoInfo):
                    self?.imageData.append(contentsOf: photoInfo.photos?.photo ?? [])
                    self?.loadingIndicator.stopAnimating()
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
        return imageData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = imageData[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: constants.reuseIdentifier, for: indexPath) as! FlickrCollectionViewCell

        guard imageData.count != 0 else {
            return cell
        }

        if indexPath.row == imageData.count - 1 {
            fetchFlickrImages(tags: tags)
        }

        fetchImages.fetchImageSize (data.id) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let urlInfo):
                    let sourceImage = urlInfo.sizes?.size[1].source
                    guard let urlPath = sourceImage else { return }
                    let image = self.imageSource.cache.object(forKey: URL(string: urlPath)! as NSURL)
                    cell.imageFlickr.backgroundColor = UIColor(white: 0.95, alpha: 1)
                    cell.imageFlickr.image = image
                    if image == nil {
                        guard let url = URL(string: urlPath) else { return }
                        self.imageSource.getImagesFromURL(from: url) { (result) in
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
                case .failure(let error):
                    print(error)
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
        tags = searchBar.text?.removeSpaceFromString ?? "kitten"
        fetchFlickrImages(tags: searchBar.text ?? "kitten")
        searchBar.text = ""
    }
}

extension FlickrCollectionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueFullScreen" {
            let fullScreenVC = segue.destination as! FullScreenViewController
            let cell = sender as! UICollectionViewCell
            let indexPath = self.collectionView.indexPath(for: cell)
            if let indexPath = indexPath {
                let photoID = imageData[indexPath.row].id
                fullScreenVC.photoID = photoID
            }
        }
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
