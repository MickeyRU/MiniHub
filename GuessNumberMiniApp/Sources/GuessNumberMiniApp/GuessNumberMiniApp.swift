import UIKit
import MiniAppInterface

public final class GuessNumberMiniApp: MiniApp, MiniAppViewProviding {
    public var viewTypeProvider: MiniAppViewProviding {
        return self
    }
    
    private lazy var guessNumberService: GuessNumberServiceProtocol = {
        let service = GuessNumberService()
        return service
    }()
    
    public var id: String
    public var visualConfiguration: MiniAppVisualConfiguration
    
    public init(id: String, visualConfiguration: MiniAppVisualConfiguration) {
        self.id = id
        self.visualConfiguration = visualConfiguration
    }
    
    public func configure(with configuration: MiniAppVisualConfiguration) {
        self.visualConfiguration = configuration
    }
    
    public func createCompactView() -> CompactView {
        return CompactView(appIcon: AssetName.appIcon.data,
                           appName: "Guess Number",
                           description: "Угадайте число за наименьшее количество попыток")
    }
    
    public func createInteractiveView() -> UIView {
        return GuessInteractiveView(guessNumberService: guessNumberService)
    }
    
    public func createFullScreenViewController() -> UIViewController {
        let viewModel = GuessNumberViewModel(with: guessNumberService)
        let viewController = GuessNumberViewController(application: self, with: viewModel)
        return viewController
    }
}

fileprivate enum AssetName: String {
    case appIcon
    
    var data: Data? {
        guard let image = UIImage(named: self.rawValue,
                                  in: Bundle.module,
                                  compatibleWith: nil) else {
            print("Failed to load image named: \(self.rawValue)")
            return nil
        }
        return image.pngData()
    }
}
