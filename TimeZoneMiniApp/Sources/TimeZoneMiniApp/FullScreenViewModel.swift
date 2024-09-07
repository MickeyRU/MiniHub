import Foundation
import Combine

enum ViewState {
    case loading
    case success
    case failure
}

protocol TimeZoneViewModelProtocol {
    var viewState: AnyPublisher<ViewState, Never> { get }
    var currentLocationTimeInfo: AnyPublisher<LocationTimeInfo?, Never> { get }
    var currentTimeInCities: AnyPublisher<[LocationTimeInfo], Never> { get }
    
    func numberOfRowsInSection() -> Int
    func cityModel(for index: Int) -> LocationTimeInfo
    func heightForRowAt(with availableSpace: CGFloat) -> CGFloat
    func getCurrentTime() -> String
    func getCurrentCityName() -> String
}

final class FullScreenViewModel: TimeZoneViewModelProtocol {
    private let viewStateSubject = CurrentValueSubject<ViewState, Never>(.loading)
    private let currentLocationTimeSubject = CurrentValueSubject<LocationTimeInfo?, Never>(nil)
    private let currentTimeInCitiesSubject = CurrentValueSubject<[LocationTimeInfo], Never>([])
    
    var viewState: AnyPublisher<ViewState, Never> {
        return viewStateSubject.eraseToAnyPublisher()
    }
    
    var currentLocationTimeInfo: AnyPublisher<LocationTimeInfo?, Never> {
        return currentLocationTimeSubject.eraseToAnyPublisher()
    }
    
    var currentTimeInCities: AnyPublisher<[LocationTimeInfo], Never> {
        return currentTimeInCitiesSubject.eraseToAnyPublisher()
    }
    
    private let application: TimeZoneMiniApp
    private let geoTimeService: GeoTimeServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(application: TimeZoneMiniApp, geoTimeService: GeoTimeServiceProtocol) {
        self.application = application
        self.geoTimeService = geoTimeService
        setupBindings()
        geoTimeService.requestLocation()
    }
    
    func numberOfRowsInSection() -> Int {
        return currentTimeInCitiesSubject.value.count
    }
    
    func cityModel(for index: Int) -> LocationTimeInfo {
        let location = currentTimeInCitiesSubject.value[index]
        return LocationTimeInfo(locationName: location.locationName, currentTime: location.currentTime)
    }
    
    func heightForRowAt(with availableSpace: CGFloat) -> CGFloat {
        return availableSpace / 8
    }
    
    func getCurrentTime() -> String {
        return currentLocationTimeSubject.value?.currentTime ?? "N/A"
    }
    
    func getCurrentCityName() -> String {
        return currentLocationTimeSubject.value?.locationName ?? "Unknown"
    }
    
    private func setupBindings() {
        let currentLocationTimePublisher = geoTimeService.currentLocationTimePublisher
        let worldCitiesTimePublisher = geoTimeService.worldCitiesTimePublisher
        
        Publishers.CombineLatest(currentLocationTimePublisher, worldCitiesTimePublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(_):
                    self?.viewStateSubject.send(.failure)
                    ErrorHandler.handle(error: AppError.customError("Произошла ошибка получения данных геолокации приложения TimeZoneMiniApp, проверьте настройки доступа к Вашей геопозиции"))
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] (locationTimeInfo, worldCitiesTimeInfos) in
                if locationTimeInfo != nil, !worldCitiesTimeInfos.isEmpty {
                    self?.currentLocationTimeSubject.send(locationTimeInfo)
                    self?.currentTimeInCitiesSubject.send(worldCitiesTimeInfos)
                    self?.viewStateSubject.send(.success)
                } else {
                    // Если данных нет или они неполные, отправляем ошибку
                    self?.viewStateSubject.send(.failure)
                    ErrorHandler.handle(error: AppError.customError("Произошла ошибка получения данных геолокации приложения TimeZoneMiniApp, проверьте настройки доступа к Вашей геопозиции"))

                }
            })
            .store(in: &cancellables)
    }
}
