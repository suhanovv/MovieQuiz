//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Вадим Суханов on 28.01.2025.
//

import Foundation

struct GameResult: Codable {
    let correct: Int
    let total: Int
    let date: Date

    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
