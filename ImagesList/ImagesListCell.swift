import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBAction func likeButtonTapped(_ sender: Any) {
        let isLiked = likeButton.currentImage == UIImage(named: "likeButtonOn.jpeg")
        let likeImage = isLiked ? UIImage(named: "likeButtonOff.jpeg") : UIImage(named: "likeButtonOn.jpeg")
        likeButton.setImage(likeImage, for: .normal)
    }
}
