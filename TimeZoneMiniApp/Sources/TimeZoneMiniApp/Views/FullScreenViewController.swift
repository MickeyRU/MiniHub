import UIKit
import Combine

final class FullScreenViewController: UIViewController {
    private let viewModel: TimeZoneViewModelProtocol
    private let aplication: TimeZoneMiniApp
    
    private var loadingView: LoadingView
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var timeTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(CitiesTimeCell.self, forCellReuseIdentifier: CitiesTimeCell.reuseIndentifier)
        return tableView
    }()
    
    
    init(application: TimeZoneMiniApp, with viewModel: TimeZoneViewModelProtocol) {
        self.aplication = application
        self.viewModel = viewModel
        self.loadingView = LoadingView()
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        self.title = aplication.viewTypeProvider.createCompactView().appName
        [timeLabel, cityLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        [stackView, timeTableView, loadingView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            timeTableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            timeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timeTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
    }
    
    private func bindViewModel() {
        viewModel.viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                self.updateUI(for: state)
            }
            .store(in: &cancellables)
        
        viewModel.currentLocationTimeInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locationTime in
                self?.cityLabel.text = locationTime?.locationName
                self?.timeLabel.text = locationTime?.currentTime
                self?.timeTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(for state: ViewState) {
        switch state {
        case .loading:
            stackView.isHidden = true
            timeTableView.isHidden = true
            loadingView.isHidden = false
            
        case .success:
            stackView.isHidden = false
            timeTableView.isHidden = false
            loadingView.isHidden = true
            
        case .failure:
            stackView.isHidden = false
            timeTableView.isHidden = false
            loadingView.isHidden = false
        }
    }
}

// MARK: - UITableViewDataSource

extension FullScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CitiesTimeCell.reuseIndentifier, for: indexPath) as? CitiesTimeCell else {
            return UITableViewCell()
        }
        let model = viewModel.cityModel(for: indexPath.row)
        cell.configure(with: model)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FullScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let availbaleSpace = calculateAvailableHeight()
        return viewModel.heightForRowAt(with: availbaleSpace)
    }
}

extension FullScreenViewController {
    private func calculateAvailableHeight() -> CGFloat {
        let safeAreaInsets = view.safeAreaInsets
        let totalHeight = view.bounds.height
        return totalHeight - safeAreaInsets.top - safeAreaInsets.bottom - stackView.bounds.height - 16
    }
}
