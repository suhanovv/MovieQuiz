//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Вадим Суханов on 02.03.2025.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quizStep: QuizStepViewModel) {
    }

    func show(alert: AlertModel) {
    }

    func highlightImageBorder(isCorrect: Bool) {
    }

    func showLoadingIndicator() {
    }

    func hideLoadingIndicator() {
    }
}


final class MovieQuizPresenterTests: XCTestCase {
    func testConvert() throws {
        // given
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)

        // when
        let emptyData = Data()
        let question = MovieQuiz.QuizQuestion(imageData: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = presenter.convert(model: question)
        
        // then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "0/10")
    }
    
    func testSwitchToNextQuestion() throws {
        // given
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        // when
        presenter.switchToNextQuestion()
        presenter.switchToNextQuestion()
        
        // then
        XCTAssertEqual(presenter.currentQuestionIndex, 2)
    }
    
    func testRestartGame() throws {
        // given
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        // when
        presenter.switchToNextQuestion()
        presenter.switchToNextQuestion()
        XCTAssertEqual(presenter.currentQuestionIndex, 2)
        presenter.restartGame()
        
        // then
        XCTAssertEqual(presenter.currentQuestionIndex, 0)
    }
}

