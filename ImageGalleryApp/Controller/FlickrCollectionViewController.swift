//
//  FlickrCollectionViewController.swift
//  ImageGalleryApp
//
//  Created by Gurjit Singh on 28/04/21.
//

import UIKit

class FlickrCollectionViewController: UICollectionViewController {

    private var viewModel = CollectionViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(viewModel.loadingIndicator)
        initialization()
    }

    private func initialization() {
        title = "Flickr Image App"
        viewModel.loadingIndicator.hidesWhenStopped = true
        viewModel.loadingIndicator.center = self.view.center
        fetchFlickrImages(tags: viewModel.tags)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imageData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = viewModel.imageData[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.constants.reuseIdentifier, for: indexPath) as! FlickrCollectionViewCell

        guard viewModel.imageData.count != 0 else {
            return cell
        }

        if indexPath.row == viewModel.imageData.count - 10 {
            fetchFlickrImages(tags: viewModel.tags)
        }

        viewModel.fetchImages.fetchImageSize (data.id) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let urlInfo):
                    let sourceImage = urlInfo.sizes?.size[1].source
                    guard let urlPath = sourceImage else { return }
                    let image = self.viewModel.imageSource.cache.object(forKey: URL(string: urlPath)! as NSURL)
                    cell.imageFlickr.backgroundColor = UIColor(white: 0.95, alpha: 1)
                    cell.imageFlickr.image = image
                    if image == nil {
                        guard let url = URL(string: urlPath) else { return }
                        self.viewModel.imageSource.getImagesFromURL(from: url) { (result) in
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

//Mark:- Fetch image data from API

extension FlickrCollectionViewController {
    func fetchFlickrImages(tags: String) {
        self.viewModel.pageCount += 1
        viewModel.loadingIndicator.startAnimating()
        viewModel.fetchImages.fetchImageDataFromFlickr(tags, viewModel.pageCount) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let photoInfo):
                    self?.viewModel.imageData.append(contentsOf: photoInfo.photos?.photo ?? [])
                    self?.viewModel.loadingIndicator.stopAnimating()
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

//Mark:- UISearchBarDelegate

extension FlickrCollectionViewController: UISearchBarDelegate {

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let searchBarView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: viewModel.constants.reuseIdentifierSearch, for: indexPath)
        return searchBarView
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.resetImagesData
        guard !(searchBar.text?.isEmpty ?? true) else {
            return
        }
        viewModel.tags = searchBar.text?.removeSpaceFromString ?? "kitten"
        fetchFlickrImages(tags: searchBar.text ?? "kitten")
        searchBar.text = ""
        self.collectionView.reloadData()
    }
}

//Mark:- Segue Full Screen

extension FlickrCollectionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueFullScreen" {
            let fullScreenVC = segue.destination as! FullScreenViewController
            let cell = sender as! UICollectionViewCell
            let indexPath = self.collectionView.indexPath(for: cell)
            if let indexPath = indexPath {
                let photoID = viewModel.imageData[indexPath.row].id
                fullScreenVC.photoID = photoID
            }
        }
    }
}

//Mark:- UICollectionViewDelegateFlowLayout

extension FlickrCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.numberOfRows(frameWidth: view.frame.width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return viewModel.constants.sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return viewModel.constants.sectionInsets.left
    }
}
