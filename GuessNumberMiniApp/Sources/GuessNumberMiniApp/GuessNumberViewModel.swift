import Foundation
import Combine

protocol GuessNumberViewModelProtocol {
    var resultPublisher: AnyPublisher<String, Never> { get }
    func makeGuess(_ guess: Int)
}

final class GuessNumberViewModel: GuessNumberViewModelProtocol {
    var resultPublisher: AnyPublisher<String, Never> {
        resultSubject.eraseToAnyPublisher()
    }
    private let service: GuessNumberServiceProtocol
    
    private let targetNumber = Int.random(in: 1...100)
    private var resultSubject = PassthroughSubject<String, Never>()
    
    init(with service: GuessNumberServiceProtocol) {
        self.service = service
    }
    
    func makeGuess(_ guess: Int) {
        let result: String
        if guess < targetNumber {
            result = "\(guess) - Слишком мало! Попробуем еще раз?!"
            service.addAttempt()
        } else if guess > targetNumber {
            result = "\(guess) - Слишком много! Попробуем еще раз?!"
            service.addAttempt()
        } else {
            service.updateGameResults()
            let attempts = service.currentAttempts()
            result = "Поздравляем! Вы угадали число за \(attempts) попыток."
        }
        resultSubject.send(result)
    }
}

