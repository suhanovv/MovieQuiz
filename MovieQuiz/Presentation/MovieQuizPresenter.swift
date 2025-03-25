//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Вадим Суханов on 02.03.2025.
//

import UIKit

final class MovieQuizPresenter {
    private(set) var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var isGameFinished: Bool {
        currentQuestionIndex == questionsAmount
    }
    private var isLastQuestion: Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?

    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        self.viewController?.showLoadingIndicator()
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        handleAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        handleAnswer(isYes: false)
    }
    
    private func handleAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let isCorrect = currentQuestion.correctAnswer == isYes
        
        if isCorrect {
            correctAnswers += 1
        }
        
        proceedWithAnswerResult(isCorrect: isCorrect)
    }
    
    private func proceedWithAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResult()
        }
    }
    
    private func proceedToNextQuestionOrResult() {
        if isGameFinished {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let alertModel = getEndGameAlertModel()
            
            viewController?.show(alert: alertModel)
        } else {
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func getEndGameAlertModel() -> AlertModel {
        
        let totalGames = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let accuracy = statisticService.totalAccuracy

        return AlertModel(
            title: "Этот раунд окончен!",
            message: """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(totalGames)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", accuracy))%
            """,
            buttonText: "Сыграть еще раз"
        ) {[weak self] in
            guard let self = self else { return }
            self.restartGame()
        }
    }
    
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        restartGame()
    }

    func didFailToLoadDataFromServer(with error: any Error) {
        viewController?.hideLoadingIndicator()
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.viewController?.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        
        viewController?.show(alert: alertModel)
    }

    func didFailToLoadFilmCover() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.viewController?.hideLoadingIndicator()
            let alertModel = AlertModel(
                title: "Ошибка",
                message: "Неудалось загрузить постер",
                buttonText: "Следующий вопрос",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.viewController?.showLoadingIndicator()
                    self.proceedToNextQuestionOrResult()
                }
            )
            self.viewController?.show(alert: alertModel)
        }
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        switchToNextQuestion()
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quizStep: viewModel)
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex)/\(questionsAmount)"
        )
    }
    
    
}
