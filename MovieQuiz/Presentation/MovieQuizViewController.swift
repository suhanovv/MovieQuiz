import UIKit

final class MovieQuizViewController: UIViewController {

    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var isGameFinished: Bool {
        return currentQuestionIndex == questionsAmount
    }
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var isReadyToAnswer = false {
        didSet {
            yesButton.isEnabled = isReadyToAnswer
            noButton.isEnabled = isReadyToAnswer
        }
    }
    private var alertPresenter: AlertPresenterProtocol?
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(controller: self)
        questionFactory = QuestionFactory(delegate: self)
        
        questionFactory?.requestNextQuestion()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        isReadyToAnswer = false
        let result = validate(userAnswer: true)
        showAnswerResult(isCorrect: result)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        isReadyToAnswer = false
        let result = validate(userAnswer: false)
        showAnswerResult(isCorrect: result)
    }
    
    private func validate(userAnswer: Bool) -> Bool {
        if userAnswer == currentQuestion?.correctAnswer {
            correctAnswers += 1
            return true
        }
        return false
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        if isGameFinished {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let alertModel = getEndGameAllertModel()
            alertPresenter?.show(alertModel: alertModel)
        } else {
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func getEndGameAllertModel() -> AlertModel {
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
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
    }
}

// MARK: Delegates
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        currentQuestionIndex += 1
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quizStep: viewModel)
            self?.isReadyToAnswer = true
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex)/\(questionsAmount)"
        )
    }
    
    private func show(quizStep step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderWidth = 0
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
}
