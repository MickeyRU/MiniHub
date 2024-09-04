import Foundation
import MiniAppInterface

protocol AppManagerProtocol {
    func getAllMiniApps() -> [MiniApp]
    func getMiniApp(by identifier: String) -> MiniApp?
    func updateMiniAppConfiguration(identifier: String, configuration: MiniAppConfiguration)
}

final class MiniAppManager: AppManagerProtocol {
    private var miniApps: [MiniApp] = []
    
    public init() {
        loadMiniApps()
    }
    
    func getAllMiniApps() -> [MiniApp] {
        return miniApps
    }
    
    func getMiniApp(by identifier: String) -> MiniApp? {
        return miniApps.first { $0.id == identifier }
    }
    
    func updateMiniAppConfiguration(identifier: String, configuration: MiniAppConfiguration) {
        guard let appIndex = miniApps.firstIndex(where: { $0.id == identifier }) else {
            return
        }
        miniApps[appIndex].configure(with: configuration)
    }
    
    private func loadMiniApps() {
        // Создаем тут
        miniApps = []
    }
}
