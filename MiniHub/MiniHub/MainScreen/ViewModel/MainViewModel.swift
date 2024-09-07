import UIKit
import Combine

protocol MainViewModelProtocol {
    var isHalfHeightMode: Bool { get }
    var miniApps: [MiniAppModel] { get }
    
    func handleOpenButtonTapped(at index: Int)
    func numberOfRowsInSection() -> Int
    func heightForRow(availableHeight: CGFloat) -> CGFloat
    func sizeControlIsTapped(isHalfHeightMode: Bool)
    func cellType(for index: Int) -> MiniAppCellType
    func model(for index: Int) -> MiniAppModel
    func InteractiveView(for index: Int) -> UIView?
}

final class MainViewModel: MainViewModelProtocol {
    private let calculateService: HeightCalculateProtocol
    private let navigationRouter: NavigationRouterProtocol
    private let miniAppManager: any AppManagerProtocol
    
    private(set) var isHalfHeightMode: Bool = false
    private(set) var miniApps = [MiniAppModel]()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationRouter: NavigationRouterProtocol, calculateService: HeightCalculateProtocol, miniAppManager: any AppManagerProtocol) {
        self.navigationRouter = navigationRouter
        self.isHalfHeightMode = false
        self.calculateService = calculateService
        self.miniAppManager = miniAppManager
        setupBindings()
    }
    
    func numberOfRowsInSection() -> Int {
        return miniApps.count
    }
    
    func heightForRow(availableHeight: CGFloat) -> CGFloat {
        return calculateService.calculateHeight(isHalfHeightMode: isHalfHeightMode, availableHeight: availableHeight)
    }
    
    func sizeControlIsTapped(isHalfHeightMode: Bool) {
        self.isHalfHeightMode.toggle()
    }
    
    func handleOpenButtonTapped(at index: Int) {
        guard index >= 0 && index < miniApps.count else { return }
        let miniApp = miniApps[index]
        
        if let viewController = miniAppManager.getMiniAppViewController(by: miniApp.appId) {
            navigationRouter.navigate(to: .miniApp(viewController))
        }
    }
    
    func model(for index: Int) -> MiniAppModel {
        return miniApps[index]
    }
    
    func InteractiveView(for index: Int) -> UIView? {
        let miniApp = miniApps[index]
        return miniAppManager.getInteractiveView(by: miniApp.appId)
    }
    
    func cellType(for index: Int) -> MiniAppCellType {
        return isHalfHeightMode ? .halfScreen : .compact
    }
    
    private func setupBindings() {
        miniAppManager.availableMiniAppsPublisher
            .sink {[weak self] miniApps in
                self?.miniApps = miniApps
            }
            .store(in: &cancellables)
    }
}
