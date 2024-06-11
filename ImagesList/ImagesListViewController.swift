import UIKit
import Foundation

class ImagesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
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
    
    // MARK: - Private Methods
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photoName = photosName[indexPath.row]
        guard let photo = UIImage(named: photoName) else {
            print("Изображение \(photoName) не найдено")
            return
        }
        cell.customImageView.image = photo
        if indexPath.row % 2 == 0 {
            cell.likeButton.setImage(UIImage(named: "likeButtonOn.jpeg"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "likeButtonOff.jpeg"), for: .normal)
        }
    }
}
