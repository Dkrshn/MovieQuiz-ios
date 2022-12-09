//
//  QuestionFactory.swift
//  MovieQuiz


import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    private enum ServerError: Error {
            case message(description: String)
        }
    
    
    private let moviesLoader: MoviesLoading
    
    private weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
            self.moviesLoader = moviesLoader
            self.delegate = delegate
        }
    
    func loadData() {
        moviesLoader.loadMovies(handler: { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.errorMessage.isEmpty {
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    } else {
                        let error = ServerError.message(description: mostPopularMovies.errorMessage)
                        self.delegate?.didFailToLoadData(with: error)
                    }
                    
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        })
    }
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            let indexRating = (7...9).randomElement() ?? 0
            let text = "Рейтинг этого фильма больше чем \(indexRating)?"
            let correctAnswer = rating > Float(indexRating)
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
            
        }
        
    }
    
}
