import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
}
