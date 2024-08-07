import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBAction func likeButtonTapped(_ sender: Any) {
        let isLiked = likeButton.currentImage == UIImage(named: "likeButtonOn.jpeg")
        let likeImage = isLiked ? UIImage(named: "likeButtonOff.jpeg") : UIImage(named: "likeButtonOn.jpeg")
        likeButton.setImage(likeImage, for: .normal)
    }
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "likeButtonOn.jpeg") : UIImage(named: "likeButtonOff.jpeg")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.kf.cancelDownloadTask()
        customImageView.image = nil
    }
}
