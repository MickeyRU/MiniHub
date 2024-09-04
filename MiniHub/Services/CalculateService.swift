import Foundation

protocol HeightCalculate {
    func calculateHeight(isHalfHeightMode: Bool, availableHeight: CGFloat) -> CGFloat
}

final class CalculateService: HeightCalculate {
    func calculateHeight(isHalfHeightMode: Bool, availableHeight: CGFloat) -> CGFloat {
        return isHalfHeightMode ? availableHeight / 2 : availableHeight / 8
    }
}
