import UIKit

final class MainViewController: UIViewController {
    private let viewModel: MainViewModelProtocol
    
    private var segmentedControlHeight: CGFloat = 0.0
    
    private lazy var appsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MiniAppCell.self, forCellReuseIdentifier: MiniAppCell.reuseIndentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Все", "Доступные"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    init(viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateTableView()
    }
    
    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         segmentedControlHeight = segmentedControl.bounds.height
         updateTableView()
     }
    
    @objc
    private func segmentedControlChanged(_ sender: UISegmentedControl) {
        viewModel.sizeControlIsTapped(isHalfHeightMode: sender.selectedSegmentIndex == 1)
        updateTableView()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        [segmentedControl, appsTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            appsTableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            appsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            appsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            appsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updateTableView() {
           appsTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MiniAppCell.reuseIndentifier, for: indexPath) as? MiniAppCell else {
            return UITableViewCell()
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let availableHeight = calculateAvailableHeight()
        return viewModel.heightForRow(availableHeight: availableHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.isHalfHeightMode {
            let miniAppViewController = UIViewController()
            navigationController?.pushViewController(miniAppViewController, animated: true)
        }
    }
}


extension MainViewController {
    private func calculateAvailableHeight() -> CGFloat {
        let safeAreaInsets = view.safeAreaInsets
        let totalHeight = view.bounds.height
        return totalHeight - safeAreaInsets.top - safeAreaInsets.bottom - segmentedControlHeight - 16
    }
}
