import UIKit
import Foundation

final class ImagesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == showSingleImageSegueIdentifier {
                guard
                    let viewController = segue.destination as? SingleImageViewController,
                    let indexPath = sender as? IndexPath
                else {
                    assertionFailure("Invalid segue destination")
                    return
                }

                let image = UIImage(named: photosName[indexPath.row])
                _ = viewController.view
                viewController.image = image
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        let currentDate = Date()
        let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMMM yyyy"
                formatter.locale = Locale(identifier: "ru_RU")
                return formatter
            }()
        let dateString = dateFormatter.string(from: currentDate)
        imageListCell.dateLabel.text = "\(dateString)"
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photoName = photosName[indexPath.row]
        
        guard let photo = UIImage(named: photoName) else {
            print("Изображение \(photoName) не найдено")
            return 44
        }
        let imageWidth = photo.size.width
        let imageHeight = photo.size.height
        let tableViewWidth = tableView.frame.width
        
        let cellHeight = tableViewWidth * imageHeight / imageWidth
        return cellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        }
    // MARK: - Private Methods
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photoName = photosName[indexPath.row]
        guard let photo = UIImage(named: photoName) else {
            print("Изображение \(photoName) не найдено")
            return
        }
        cell.customImageView.image = photo
        let isLiked = indexPath.row % 2 != 0
        let likeImage = isLiked ? UIImage(named: "likeButtonOn.jpeg") : UIImage(named: "likeButtonOff.jpeg")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    }
    

