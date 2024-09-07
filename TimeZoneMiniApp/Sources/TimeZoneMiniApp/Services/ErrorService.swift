import UIKit

enum AppError: Error, Equatable {
    case locationAccessError
    case locationFindError(String)
    case customError(String)
}

final class ErrorHandler {
    static func handle(error: AppError, handler: (() -> Void)? = nil) {
        showAlert(title: "Упс....  у нас ошибка!",
                  message: message(for: error),
                  handler: handler)
    }

    private static func message(for error: AppError) -> String {
        switch error {
        case .locationAccessError:
            return "Для работы мини - приложения TimeZoneApp необходимо предоставить доступ к геолокации."
        case .locationFindError(let massage):
            return massage
        case .customError(let massage):
            return massage
        }
    }

    private static func showAlert(title: String, message: String, handler: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                if let handler = handler {
                    handler()
                }
            }))
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true, completion: nil)
            }
        }
    }
}
