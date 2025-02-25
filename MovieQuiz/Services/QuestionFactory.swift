//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Вадим Суханов on 25.01.2025.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {

    private var movies: [MostPopularMovie] = []
    
    private weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoaderProtocol
    
    
    init(moviesLoader: MoviesLoaderProtocol, delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    // MARK: - load movies
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadDataFromServer(with: error)
                }
            }
        }
    }
    
    // MARK: - methods for requesting next question
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            let question = getQuizQuestion(fromMostPopularMovie: movie)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }

    }
    
    private func getQuizQuestion(fromMostPopularMovie movie: MostPopularMovie) -> QuizQuestion {
        var imageData = Data()
        
        do {
            imageData = try Data(contentsOf: movie.resizedImageURL)
        } catch {
            self.delegate?.didFailToLoadFilmCover()
        }
        
        
        let rating = Float(movie.rating) ?? 0
        let avgRating = getAvgMoviesRating()
        let text = "Рейтинг этого фильма больше чем \(String(format: "%0.1f", avgRating))?"
        let correctAnswer = rating > avgRating
        
        return QuizQuestion(
            imageData: imageData,
            text: text,
            correctAnswer: correctAnswer)
    }
    
    private func getAvgMoviesRating() -> Float {
        if movies.isEmpty {
            return 0
        }
        return movies.reduce(0) { result, movie in
            result + (Float(movie.rating) ?? 0)
        } / Float(movies.count)
    }
}
