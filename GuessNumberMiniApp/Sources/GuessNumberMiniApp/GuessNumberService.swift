import Foundation
import Combine

protocol GuessNumberServiceProtocol {
    var bestScorePublisher: AnyPublisher<Int, Never> { get }
    
    func addAttempt()
    func updateGameResults()
    func currentAttempts() -> Int
    func resetGameStats()
}

final class GuessNumberService: GuessNumberServiceProtocol {
    var bestScorePublisher: AnyPublisher<Int, Never> {
        bestScoreSubject.eraseToAnyPublisher()
    }
    
    private var bestScoreSubject = CurrentValueSubject<Int, Never>(0)
    
    private var gameCounts: Int = 0
    private var bestScore: Int = Int.max {
        didSet {
            bestScoreSubject.send(bestScore)
        }
    }
    
    func addAttempt() {
        gameCounts += 1
    }
    
    func updateGameResults() {
        addAttempt()
        let attempts = currentAttempts()
        bestScore = min(bestScore, attempts)
    }
    
    func resetGameStats() {
        gameCounts = 0
        bestScore = 0
    }
    
    func currentAttempts() -> Int {
        return gameCounts
    }
}
