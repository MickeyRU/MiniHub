import UIKit
import Combine
import MiniAppInterface
import TimeZoneMiniApp
import GuessNumberMiniApp

protocol AppManagerProtocol: ObservableObject {
    var availableMiniAppsPublisher: AnyPublisher<[MiniAppModel], Never> { get }
    func getMiniAppViewController(by id: String) -> UIViewController?
    func getInteractiveView(by id: String) -> UIView?
//    func loadMoreMiniApps(
}

final class MiniAppManager: AppManagerProtocol {
    var availableMiniAppsPublisher: AnyPublisher<[MiniAppModel], Never> {
        $availableMiniApps.eraseToAnyPublisher()
    }
    
    @Published private(set) var availableMiniApps: [MiniAppModel] = []
    private var miniAppsDictionary: [String: MiniApp] = [:]
    
    init() {
        loadMiniApps()
    }
    
    func getMiniAppViewController(by id: String) -> UIViewController? {
        guard let miniApp = miniAppsDictionary[id] else { return nil }
        return miniApp.viewTypeProvider.createFullScreenViewController()
    }
    
    func getInteractiveView(by id: String) -> UIView? {
        guard let miniApp = miniAppsDictionary[id] else { return nil }
        return miniApp.viewTypeProvider.createInteractiveView()
    }
    
    private func loadMiniApps() {
        (0..<6).forEach { _ in
            let timeZoneMiniApp = createTimeZoneMiniApp()
            miniAppsDictionary[timeZoneMiniApp.id] = timeZoneMiniApp
            let timeZoneMiniAppModel = convertToCommonMiniAppModel(from: timeZoneMiniApp)
            availableMiniApps.append(timeZoneMiniAppModel)
            let guessNumberMiniApp = createCrosswordMiniApp()
            miniAppsDictionary[guessNumberMiniApp.id] = guessNumberMiniApp
            let guessNumberMiniAppModel = convertToCommonMiniAppModel(from: guessNumberMiniApp)
            availableMiniApps.append(guessNumberMiniAppModel)
        }
    }
    
    private func createTimeZoneMiniApp() -> MiniApp {
        return TimeZoneMiniApp(id: UUID().uuidString,
                               configuration: MiniAppVisualConfiguration(backgroundColor: .systemBackground))
    }
    
    private func createCrosswordMiniApp() -> MiniApp {
        return GuessNumberMiniApp(id: UUID().uuidString,
                                visualConfiguration: MiniAppVisualConfiguration(backgroundColor: .systemBackground))
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
