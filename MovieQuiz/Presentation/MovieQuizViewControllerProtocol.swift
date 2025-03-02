//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Вадим Суханов on 02.03.2025.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quizStep: QuizStepViewModel)
    func show(alert: AlertModel)
    
    func highlightImageBorder(isCorrect: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}
