import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell, ImagesListCellProtocol {
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - UI Elements
    private(set) lazy var cellImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private(set) lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "LikeButton"
        return button
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .ypWhite
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Constants
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupCell() {
        contentView.clipsToBounds = true
        contentView.backgroundColor = .ypLightBlack
        
        [cellImage, dateLabel, likeButton].forEach { contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor, constant: 8),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: -8),
            
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellImage.trailingAnchor, constant: -8)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
    }
    
    // MARK: - Public methods
    func setImage(from url: URL) {
        cellImage.contentMode = .center
        likeButton.isHidden = true
        dateLabel.isHidden = true
        
        let resource = KF.ImageResource(downloadURL: url, cacheKey: url.absoluteString)
        
        cellImage.kf.setImage(with: resource,
                              placeholder: UIImage(named: "placeholder"),
                              options: [.transition(.fade(0.3))]) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.cellImage.contentMode = .scaleAspectFill
                self.cellImage.image = imageResult.image
                self.likeButton.isHidden = false
                self.dateLabel.isHidden = false
            case .failure:
                self.cellImage.contentMode = .center
                self.likeButton.isHidden = true
                self.dateLabel.isHidden = true
            }
        }
        cellImage.kf.indicatorType = .activity
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "Active" : "No Active"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    // MARK: - Actions
    @objc private func didTapLikeButton() {
        delegate?.imageListCellDidTapLike(self)
    }
}
