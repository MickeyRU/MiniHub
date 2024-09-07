import CoreLocation
import Combine

protocol GeoTimeServiceProtocol {
    var currentLocationTimePublisher: AnyPublisher<LocationTimeInfo?, AppError> { get }
    var worldCitiesTimePublisher: AnyPublisher<[LocationTimeInfo], AppError> { get }
    func requestLocation()
}

final class GeoTimeService: NSObject, GeoTimeServiceProtocol {
    var currentLocationTimePublisher: AnyPublisher<LocationTimeInfo?, AppError> {
        currentLocationTimeSubject.eraseToAnyPublisher()
    }
    
    var worldCitiesTimePublisher: AnyPublisher<[LocationTimeInfo], AppError> {
        worldCitiesTimeSubject.eraseToAnyPublisher()
    }
    
    private let locationManager: CLLocationManager
    private let currentLocationTimeSubject = PassthroughSubject<LocationTimeInfo?, AppError>()
    private let worldCitiesTimeSubject = PassthroughSubject<[LocationTimeInfo], AppError>()
    
    private let cities = [
        (name: "London", timeZone: TimeZone(identifier: "Europe/London")!),
        (name: "New York", timeZone: TimeZone(identifier: "America/New_York")!),
        (name: "Tokyo", timeZone: TimeZone(identifier: "Asia/Tokyo")!),
        (name: "Sydney", timeZone: TimeZone(identifier: "Australia/Sydney")!),
        (name: "Moscow", timeZone: TimeZone(identifier: "Europe/Moscow")!)
    ]
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private var timer: DispatchSourceTimer?
    private var currentLocationTimeZone: TimeZone?
    private var currentLocationName: String?
    
    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        checkLocationAuthorization()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            currentLocationTimeSubject.send(completion: .failure(.locationAccessError))
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        @unknown default:
            break
        }
    }
    
    private func startUpdatingTime() {
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now(), repeating: 1)
        timer?.setEventHandler { [weak self] in
            self?.updateWorldCitiesTime()
            if let timeZone = self?.currentLocationTimeZone, 
                let name = self?.currentLocationName {
                self?.updateCurrentLocationTime(for: timeZone, name: name)
            }
        }
        timer?.resume()
    }
    
    private func stopUpdatingTime() {
        timer?.cancel()
        timer = nil
    }

    deinit {
        stopUpdatingTime()
    }
    
    private func getCurrentTime(for timeZone: TimeZone) -> String {
        let currentDate = Date()
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: currentDate)
    }
    
    private func updateWorldCitiesTime() {
        let updatedCities = cities.map { city in
            LocationTimeInfo(
                locationName: city.name,
                currentTime: getCurrentTime(for: city.timeZone)
            )
        }
        worldCitiesTimeSubject.send(updatedCities)
    }
    
    private func updateCurrentLocationTime(for timeZone: TimeZone, name: String) {
        let locationTimeInfo = LocationTimeInfo(
            locationName: name,
            currentTime: getCurrentTime(for: timeZone)
        )
        currentLocationTimeSubject.send(locationTimeInfo)
    }
    
    private func getTimeZone(for location: CLLocation, completion: @escaping (TimeZone?, String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil, 
                    let placemark = placemarks?.first
            else {
                completion(nil, nil)
                return
            }
            let timeZone = placemark.timeZone
            let name = placemark.locality ?? "Unknown Location"
            completion(timeZone, name)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension GeoTimeService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            self.currentLocationTimeSubject.send(completion: .failure(.locationFindError("Ошибка определения геолокации")))
            return
        }
        getTimeZone(for: location) { [weak self] timeZone, name in
            guard let timeZone = timeZone, let name = name else {
                self?.currentLocationTimeSubject.send(completion: .failure(.locationFindError("Ошибка определения таймзоны или имени локации")))
                return
            }
            self?.currentLocationTimeZone = timeZone
            self?.currentLocationName = name
            self?.updateCurrentLocationTime(for: timeZone, name: name)
            self?.updateWorldCitiesTime()
            self?.startUpdatingTime()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocationTimeSubject.send(completion: .failure(.locationFindError("Ошибка определения геолокации")))
    }
}


// MARK: - Модель данных

struct LocationTimeInfo {
    let id: String
    let locationName: String
    let currentTime: String
    
    init(id: String = UUID().uuidString, locationName: String, currentTime: String) {
        self.id = id
        self.locationName = locationName
        self.currentTime = currentTime
    }
}
