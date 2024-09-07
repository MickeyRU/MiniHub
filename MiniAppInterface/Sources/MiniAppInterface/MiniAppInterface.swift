import UIKit

public protocol MiniApp {
    var id: String { get }
    var visualConfiguration: MiniAppVisualConfiguration { get set }
    var viewTypeProvider: MiniAppViewProviding { get }

    func configure(with visualConfiguration: MiniAppVisualConfiguration)
}

public protocol MiniAppViewProviding {
    func createCompactView() -> CompactView
    func createInteractiveView() -> UIView
    func createFullScreenViewController() -> UIViewController
}

public struct MiniAppVisualConfiguration {
    public var backgroundColor: UIColor
    
    public init(backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
    }
}

public struct CompactView {
    public let appIcon: Data?
    public let appName: String
    public let description: String
    
    public init(appIcon: Data?, appName: String, description: String) {
        self.appIcon = appIcon
        self.appName = appName
        self.description = description
    }
}
