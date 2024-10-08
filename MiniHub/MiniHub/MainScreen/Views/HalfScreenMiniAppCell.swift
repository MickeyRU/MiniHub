import UIKit

final class HalfScreenMiniAppCell: UITableViewCell {
    static let reuseIndentifier = "HalfScreenMiniAppCell"
    
    let data = ["Option 1", "Option 2", "Option 3"]
    
    private lazy var appImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private var appName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private var appDescription: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        label.textAlignment = .center
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
    
    private lazy var appStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var interactiveContainer: UIView = {
        let view = UIView()
        return view
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
        interactiveContainer.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func configure(with model: MiniAppModel, interactiveView: UIView?) {
        if let appIconData = model.appIconImage,
           let appIcon = UIImage(data: appIconData) {
            self.appImageView.image = appIcon
        } else {
            self.appImageView.image = UIImage.noIcon
        }
        self.appName.text = model.appName
        self.appDescription.text = model.appDescripion
        self.contentView.backgroundColor = model.appStyle.backgroundColor
        
        
        guard let interactiveView = interactiveView else { return }
        interactiveContainer.addSubview(interactiveView)
        setupInteractiveViewConstraints(interactiveView)
    }
    
    private func setupViews() {
        setupCellAppearance()
        
        [appImageView, appName, openButton].forEach {
            appStackView.addArrangedSubview($0)
        }
        
        [appStackView, appDescription, interactiveContainer].forEach {
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
            appImageView.widthAnchor.constraint(equalToConstant: 80),
            appImageView.heightAnchor.constraint(equalToConstant: 80),
            
            appStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            appStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            appStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            appDescription.topAnchor.constraint(equalTo: appStackView.bottomAnchor, constant: 16),
            appDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            appDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            interactiveContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            interactiveContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            interactiveContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            interactiveContainer.topAnchor.constraint(equalTo: appDescription.bottomAnchor, constant: 16)
        ])
    }
    
    private func setupInteractiveViewConstraints(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: interactiveContainer.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: interactiveContainer.trailingAnchor),
            view.topAnchor.constraint(equalTo: interactiveContainer.topAnchor),
            view.bottomAnchor.constraint(equalTo: interactiveContainer.bottomAnchor)
        ])
    }
    
    @objc
    private func openButtonTapped() {
        onOpenButtonTapped?()
    }
}
