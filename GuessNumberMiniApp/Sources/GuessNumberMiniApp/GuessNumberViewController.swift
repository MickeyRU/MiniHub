import UIKit
import Combine

final class GuessNumberViewController: UIViewController {
    private let viewModel: GuessNumberViewModelProtocol
    private let aplication: GuessNumberMiniApp
    
    private let guessTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.placeholder = "Введите число от 0 до 100"
        return textField
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var guessButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemGray6
        config.baseForegroundColor = .systemBlue
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        
        var titleAttributes = AttributeContainer()
        titleAttributes.font = .systemFont(ofSize: 12, weight: .bold)
        config.attributedTitle = AttributedString("Проверить", attributes: titleAttributes)
        button.configuration = config
        button.addTarget(self, action: #selector(guessButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private var guessStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(application: GuessNumberMiniApp, with viewModel: GuessNumberViewModelProtocol) {
        self.aplication = application
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    
    private func setupViews() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        view.backgroundColor = .systemBackground
        self.title = aplication.viewTypeProvider.createCompactView().appName
        [guessTextField, guessButton, resultLabel].forEach {
            guessStackView.addArrangedSubview($0)
        }
        guessStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(guessStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            guessStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guessStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 1 / 3),
            guessTextField.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    private func bindViewModel() {
        viewModel.resultPublisher
            .sink { [weak self] result in
                self?.resultLabel.text = result
            }
            .store(in: &cancellables)
    }
    
    @objc
    private func guessButtonTapped() {
        guard
            let text = guessTextField.text,
            let guess = Int(text)
        else { return }
        viewModel.makeGuess(guess)
        guessTextField.text = nil
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension GuessNumberViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        let isNumeric = newString.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        return isNumeric
    }
}
