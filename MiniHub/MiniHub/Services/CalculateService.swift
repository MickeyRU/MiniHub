import Foundation

protocol HeightCalculateProtocol {
    func calculateHeight(isHalfHeightMode: Bool, availableHeight: CGFloat) -> CGFloat
}

final class CalculateService: HeightCalculateProtocol {
    func calculateHeight(isHalfHeightMode: Bool, availableHeight: CGFloat) -> CGFloat {
        return isHalfHeightMode ? availableHeight / 2 : availableHeight / 8
    }
}
