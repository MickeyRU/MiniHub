import UIKit
import Combine
import MiniAppInterface
import TimeZoneMiniApp

protocol AppManagerProtocol: ObservableObject {
    var availableMiniAppsPublisher: AnyPublisher<[MiniAppModel], Never> { get }
    func getMiniAppViewController(by id: String) -> UIViewController?
    func getInteractiveView(by id: String) -> UIView?
}

final class MiniAppManager: AppManagerProtocol {
    @Published private(set) var availableMiniApps: [MiniAppModel] = []
    
    private var miniAppsDictionary: [String: MiniApp] = [:]
    
    var availableMiniAppsPublisher: AnyPublisher<[MiniAppModel], Never> {
        $availableMiniApps.eraseToAnyPublisher()
    }
    
    init() {
        loadMiniApps()
    }
    
    func getMiniAppViewController(by id: String) -> UIViewController? {
        guard let miniApp = miniAppsDictionary[id] else { return nil }
        return miniApp.viewTypeProvider.createFullScreenViewController()
    }
    
    private func loadMiniApps() {
        (0..<11).forEach { _ in
            let timeZoneMiniApp = createTimeZoneMiniApp()
            miniAppsDictionary[timeZoneMiniApp.id] = timeZoneMiniApp
            let miniAppModel = convertToCommonMiniAppModel(from: timeZoneMiniApp)
            availableMiniApps.append(miniAppModel)
        }
    }
    
    func getInteractiveView(by id: String) -> UIView? {
        guard let miniApp = miniAppsDictionary[id] else { return nil }
        return miniApp.viewTypeProvider.createInteractiveView()
    }
    
    private func createTimeZoneMiniApp() -> MiniApp {
        return TimeZoneMiniApp(id: UUID().uuidString, configuration: MiniAppVisualConfiguration(backgroundColor: .systemBackground))
    }
    
    private func convertToCommonMiniAppModel(from miniApp: MiniApp) -> MiniAppModel {
        let compactView = miniApp.viewTypeProvider.createCompactView()
        return MiniAppModel(appIconImage: compactView.appIcon,
                            appName: compactView.appName,
                            appId: miniApp.id,
                            appDescripion: compactView.description,
                            appStyle: AppVisualStyle(backgroundColor: miniApp.visualConfiguration.backgroundColor)
        )
    }
    
    private func miniAppFor(id: String) -> MiniApp? {
        return miniAppsDictionary[id]
    }
}
