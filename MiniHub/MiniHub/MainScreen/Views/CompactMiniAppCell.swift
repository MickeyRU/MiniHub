import UIKit

final class CompactMiniAppCell: UITableViewCell {
    static let reuseIndentifier = "CompactMiniAppCell"
    
    private lazy var appImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private var appName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private var appDescription: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        return label
    }()
    
    private var openButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .buttonBG
        config.baseForegroundColor = .systemBlue
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        
        var titleAttributes = AttributeContainer()
        titleAttributes.font = .systemFont(ofSize: 12, weight: .bold)
        config.attributedTitle = AttributedString("Открыть", attributes: titleAttributes)
        button.configuration = config
        return button
    }()
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [appName, appDescription])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    var onOpenButtonTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        appImageView.image = nil
        appName.text = nil
        appDescription.text = nil
        contentView.backgroundColor = nil
    }
    
    func configure(with model: MiniAppModel) {
        if let appIconData = model.appIconImage,
           let appIcon = UIImage(data: appIconData) {
            appImageView.image = appIcon
        } else {
            appImageView.image = UIImage.noIcon
        }
        appName.text = model.appName
        appDescription.text = model.appDescripion
        contentView.backgroundColor = model.appStyle.backgroundColor
    }
    
    private func setupViews() {
        setupCellAppearance()
        
        [appImageView, textStackView, openButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        openButton.addTarget(self, action: #selector(openButtonTapped), for: .touchUpInside)
        setupConstraints()
    }
    
    private func setupCellAppearance() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            appImageView.heightAnchor.constraint(equalToConstant: 60),
            appImageView.widthAnchor.constraint(equalTo: appImageView.heightAnchor),
            appImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            appImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            textStackView.centerYAnchor.constraint(equalTo: appImageView.centerYAnchor),
            textStackView.leadingAnchor.constraint(equalTo: appImageView.trailingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(lessThanOrEqualTo: openButton.leadingAnchor, constant: -8),
            
            openButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            openButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc 
    private func openButtonTapped() {
        onOpenButtonTapped?()
    }
}
