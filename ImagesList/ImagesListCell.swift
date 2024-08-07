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
