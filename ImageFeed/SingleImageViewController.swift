import Foundation
import UIKit

final class SingleImageViewController: UIViewController {
    
    var imageURL: URL? {
        didSet {
            guard isViewLoaded, let imageURL else { return }
            loadImage(from: imageURL)
        }
    }
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    @IBAction func didTapBackward(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        
        guard let imageURL else { return }
        loadImage(from: imageURL)
    }
    private func loadImage(from url: URL) {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Placeholder"),
            options: nil,
            progressBlock: nil,
            completionHandler: { [weak self] result in
                guard let self = self else { return }
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let value):
                    self.imageView.image = value.image
                    self.imageView.frame.size = value.image.size
                    self.rescaleAndCenterImageInScrollView(image: value.image)
                case .failure:
                    self.showError()
                }
            }
        )
    }
    private func showError() {
        let alert = UIAlertController(title: nil, message: "Что-то пошло не так. Попробовать ещё раз?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            if let url = self?.imageURL {
                self?.loadImage(from: url)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
