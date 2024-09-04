import UIKit

public protocol MiniApp {
    var name: String { get }
    var viewController: UIViewController { get }
    var id: String { get }
    var configuration: MiniAppConfiguration { get set }

    func configure(with configuration: MiniAppConfiguration)
}
