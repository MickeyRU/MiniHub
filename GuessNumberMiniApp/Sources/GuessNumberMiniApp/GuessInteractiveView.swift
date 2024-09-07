import UIKit
import Combine

final class GuessInteractiveView: UIView {
    private let service: GuessNumberServiceProtocol
    
    private var bestScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.text = "Лучший результат: n/a"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var eraseButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemGray6
        config.baseForegroundColor = .systemBlue
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        
        var titleAttributes = AttributeContainer()
        titleAttributes.font = .systemFont(ofSize: 12, weight: .bold)
        config.attributedTitle = AttributedString("Стереть", attributes: titleAttributes)
        button.configuration = config
        return button
    }()
    
    private lazy var guessStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.axis = .vertical
        return stackView
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(guessNumberService: GuessNumberServiceProtocol) {
        self.service = guessNumberService
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        setupViews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        eraseButton.addTarget(self, action: #selector(eraseButtonTapped), for: .touchUpInside)
        
        [bestScoreLabel, eraseButton].forEach {
            guessStackView.addArrangedSubview($0)
        }
        
        guessStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(guessStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            guessStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            guessStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            guessStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupBindings() {
        service.bestScorePublisher
            .sink { [weak self] bestScore in
                DispatchQueue.main.async {
                    self?.bestScoreLabel.text = "Лучший результат: \(bestScore)"
                }
            }
            .store(in: &cancellables)
    }
    
    @objc
    private func eraseButtonTapped() {
        service.resetGameStats()
    }
}
