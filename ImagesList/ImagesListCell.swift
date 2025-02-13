import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

protocol ImagesListCellProtocol {
    var customImageView: UIImageView! { get }
    var dateLabel: UILabel! { get }
    func configure(with photo: Photo)
    func setIsLiked(_ isLiked: Bool)
}

final class ImagesListCell: UITableViewCell, ImagesListCellProtocol {
    
    weak var delegate: ImagesListCellDelegate?
    
    private let isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = .current
        return formatter
    }()
    
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "likeButtonOn.jpeg") : UIImage(named: "likeButtonOff.jpeg")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    func configure(with photo: Photo) {
        customImageView.kf.indicatorType = .activity
        if let url = URL(string: photo.thumbImageURL) {
            customImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "Placeholder"),
                options: nil,
                progressBlock: nil,
                completionHandler: { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.setNeedsLayout()
                        case .failure(let error):
                            print("Error loading image: \(error.localizedDescription)")
                        }
                    }
                }
            )
        }
        
        if let createdAtString = photo.createdAt,
           let createdAt = isoDateFormatter.date(from: createdAtString) {
            dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            dateLabel.text = "Unknown date"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.kf.cancelDownloadTask()
        customImageView.image = nil
    }
}
