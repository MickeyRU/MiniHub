import UIKit
import MiniAppInterface

public final class TimeZoneMiniApp: MiniApp, MiniAppViewProviding {
    public var viewTypeProvider: MiniAppViewProviding {
        return self
    }
    
    public var id: String
    public var visualConfiguration: MiniAppVisualConfiguration
    
    private lazy var geoTimeService: GeoTimeServiceProtocol = {
        return GeoTimeService()
    }()
    
    public init(id: String, configuration: MiniAppVisualConfiguration) {
        self.id = id
        self.visualConfiguration = configuration
    }
    
    public func configure(with configuration: MiniAppVisualConfiguration) {
        self.visualConfiguration = configuration
    }
    
    public func createInteractiveView() -> UIView {
        return InteractiveView(geoTimeService: geoTimeService)
    }
    
    public func createCompactView() -> CompactView {
        return CompactView(appIcon: AssetName.appIcon.data,
                           appName: "Time Zone",
                           description: "Время в текущей локации и в разных городах")
    }
    
    public func createFullScreenViewController() -> UIViewController {
        let viewModel = FullScreenViewModel(application: self,  geoTimeService: geoTimeService)
        let viewController = FullScreenViewController(application: self, with: viewModel)
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
