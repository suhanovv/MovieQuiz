//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Вадим Суханов on 30.01.2025.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
    }
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correct.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameResult {
        get {
            let gameData = storage.data(forKey: "\(Keys.bestGame.rawValue)")
            if let gameResult = try? JSONDecoder().decode(GameResult.self, from: gameData ?? Data()) {
                return gameResult
            }
            return GameResult(correct: 0, total: 0, date: Date())
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                storage.set(data, forKey: "\(Keys.bestGame.rawValue)")
            }
        }
    }

    var totalAccuracy: Double {
        Double(correctAnswers) / Double(10 * gamesCount) * 100
    }

    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        correctAnswers += count
        
        let currentResult = GameResult(correct: count, total: amount, date: Date())
        if currentResult.isBetterThan(bestGame) {
            bestGame = currentResult
        }
    }

    
}
