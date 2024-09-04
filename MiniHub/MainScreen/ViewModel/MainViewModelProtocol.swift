import Foundation

protocol MainViewModelProtocol {
    var isHalfHeightMode: Bool { get }

    func numberOfRowsInSection() -> Int
    func heightForRow(availableHeight: CGFloat) -> CGFloat
    func sizeControlIsTapped(isHalfHeightMode: Bool)
}

final class MainViewModel: MainViewModelProtocol {
    private let calculateService: HeightCalculate
    private(set) var isHalfHeightMode: Bool = false
    
    init(calculateService: HeightCalculate) {
        self.isHalfHeightMode = false
        self.calculateService = calculateService
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
