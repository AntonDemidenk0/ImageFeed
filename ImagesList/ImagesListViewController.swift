import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ImagesListViewControllerProtocol {
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    let imagesListService = ImagesListService.shared
    private var presenter: ImagesListPresenterProtocol?
    var photos: [Photo] = []
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        presenter = ImagesListPresenter(view: self, imagesListService: imagesListService)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhotosUpdated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        presenter?.fetchNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                indexPath.row < photos.count
            else {
                assertionFailure("Invalid segue destination or index out of range")
                return
            }
            let photo = photos[indexPath.row]
            let imageURL = URL(string: photo.largeImageURL)
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        presenter?.configureCell(imageListCell, at: indexPath)
        
        return imageListCell
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        guard oldCount != newCount else { return }
        print("Updating table view. Old count: \(oldCount), New count: \(newCount)")
        photos = imagesListService.photos
        
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageWidth = photo.size.width
        let imageHeight = photo.size.height
        let tableViewWidth = tableView.frame.width
        
        let cellHeight = tableViewWidth * imageHeight / imageWidth
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row + 1 == photos.count else { return }
        presenter?.fetchNextPage()
    }
    
    func configure(presenter: ImagesListPresenterProtocol) {
            self.presenter = presenter
        }
    
    // MARK: - Private Methods
    
    @objc private func handlePhotosUpdated() {
        presenter?.handlePhotosUpdated()
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                let alert = UIAlertController(title: "Ошибка", message: "Не удалось выполнить операцию", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}


