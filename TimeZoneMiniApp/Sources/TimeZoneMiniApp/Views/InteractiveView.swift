import UIKit
import Combine

final class InteractiveView: UIView {
    private let geoTimeService: GeoTimeServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var locationsArray: [LocationTimeInfo] = []
    private var selectedLocationIndex = 0
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "Loading..."
        label.textAlignment = .center
        return label
    }()
    
    private lazy var cityPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    private var timeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .vertical
        return stackView
    }()
    
    init(geoTimeService: GeoTimeServiceProtocol) {
        self.geoTimeService = geoTimeService
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        setupViews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [timeLabel, cityPicker].forEach {
            timeStackView.addArrangedSubview($0)
        }
        
        timeStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            timeStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            timeStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeStackView.widthAnchor.constraint(equalToConstant: 200),
            timeStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        geoTimeService.worldCitiesTimePublisher
            .sink { [weak self] result in
                switch result {
                case .failure(_):
                    ErrorHandler.handle(error: AppError.customError("Произошла ошибка получения данных геолокации приложения TimeZoneMiniApp, проверьте настройки доступа к Вашей геопозиции"))
                case .finished:
                    break
                }
            } receiveValue: { [weak self] locationTimes in
                guard let self = self else { return }
                self.updateLocationArray(income: locationTimes)
                let newLocationTime = locationTimes[self.selectedLocationIndex].currentTime
                
                DispatchQueue.main.async {
                    self.timeLabel.text = newLocationTime
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateLocationArray(income: [LocationTimeInfo]) {
        guard locationsArray.count != income.count else { return }
        locationsArray = income
        DispatchQueue.main.async {
            self.cityPicker.reloadAllComponents()
        }
    }
}

extension InteractiveView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locationsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locationsArray[row].locationName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLocationIndex = row
    }
}
