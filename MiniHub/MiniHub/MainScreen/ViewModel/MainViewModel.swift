import Foundation

protocol MainViewModelProtocol {
    var isHalfHeightMode: Bool { get }

    func numberOfRowsInSection() -> Int
    func heightForRow(availableHeight: CGFloat) -> CGFloat
    func sizeControlIsTapped(isHalfHeightMode: Bool)
}

final class MainViewModel: MainViewModelProtocol {
    private let calculateService: HeightCalculateProtocol
    private let miniAppManager: AppManagerProtocol
    private(set) var isHalfHeightMode: Bool = false
    
    init(calculateService: HeightCalculateProtocol, miniAppManager: AppManagerProtocol) {
        self.isHalfHeightMode = false
        self.calculateService = calculateService
        self.miniAppManager = miniAppManager
    }
    
    func numberOfRowsInSection() -> Int {
        return 10
    }
    
    func heightForRow(availableHeight: CGFloat) -> CGFloat {
        return calculateService.calculateHeight(isHalfHeightMode: isHalfHeightMode, availableHeight: availableHeight)
    }
    
    func sizeControlIsTapped(isHalfHeightMode: Bool) {
        self.isHalfHeightMode.toggle()
    }
}
