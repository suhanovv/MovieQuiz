//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Вадим Суханов on 25.01.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadDataFromServer(with error: Error)
}
