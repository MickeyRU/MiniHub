import UIKit

final class MainViewController: UIViewController {
    private let viewModel: MainViewModelProtocol
    private var segmentedControlHeight: CGFloat = 0.0
    
    private lazy var appsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CompactMiniAppCell.self, forCellReuseIdentifier: CompactMiniAppCell.reuseIndentifier)
        tableView.register(HalfScreenMiniAppCell.self, forCellReuseIdentifier: HalfScreenMiniAppCell.reuseIndentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Доступные", "Интерактивный режим"])
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
        self.title = "MiniHub"
        view.backgroundColor = .systemBackground
        [segmentedControl, appsTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        let cellType = viewModel.cellType(for: indexPath.row)
        let model = viewModel.model(for: indexPath.row)
        let view = viewModel.InteractiveView(for: indexPath.row)
        
        switch cellType {
        case .compact:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CompactMiniAppCell.reuseIndentifier, for: indexPath) as? CompactMiniAppCell else {
                return UITableViewCell()
            }
            configureCell(cell, with: model, interactiveView: nil, at: indexPath)
            return cell
        case .halfScreen:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HalfScreenMiniAppCell.reuseIndentifier, for: indexPath) as? HalfScreenMiniAppCell else {
                return UITableViewCell()
            }
            configureCell(cell, with: model, interactiveView: view, at: indexPath)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let availableHeight = calculateAvailableHeight()
        return viewModel.heightForRow(availableHeight: availableHeight)
    }
}


extension MainViewController {
    private func calculateAvailableHeight() -> CGFloat {
        let safeAreaInsets = view.safeAreaInsets
        let totalHeight = view.bounds.height
        return totalHeight - safeAreaInsets.top - safeAreaInsets.bottom - segmentedControlHeight - 16
    }
    
    private func configureCell(_ cell: UITableViewCell, with model: MiniAppModel, interactiveView: UIView?, at indexPath: IndexPath) {
        if let compactCell = cell as? CompactMiniAppCell {
            compactCell.configure(with: model)
            compactCell.onOpenButtonTapped = { [weak self] in
                self?.viewModel.handleOpenButtonTapped(at: indexPath.row)
            }
        } else if let halfScreenCell = cell as? HalfScreenMiniAppCell {
            halfScreenCell.configure(with: model, interactiveView: interactiveView)
            halfScreenCell.onOpenButtonTapped = { [weak self] in
                self?.viewModel.handleOpenButtonTapped(at: indexPath.row)
            }
        }
    }
}
