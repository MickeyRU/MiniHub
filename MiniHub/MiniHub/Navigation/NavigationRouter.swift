import UIKit

enum NavigationDestination {
    case miniApp(UIViewController)
}

protocol NavigationRouterProtocol {
    func startNavigation()
    func navigate(to destination: NavigationDestination)
}

final class NavigationRouter: NavigationRouterProtocol {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func startNavigation() {
        let calculateService = CalculateService()
        let miniAppManager = MiniAppManager()
        let viewModel = MainViewModel(navigationRouter: self, calculateService: calculateService, miniAppManager: miniAppManager)
        let viewController = MainViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func navigate(to destination: NavigationDestination) {
        switch destination {
        case .miniApp(let viewController):
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
