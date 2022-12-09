//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Даниил Крашенинников on 04.01.2023.
//

import UIKit


final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var viewController: MovieQuizViewControllerProtocol?
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func addCorrectAnswers() {
        correctAnswers += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func noButtonClicked() {
       didAnswer(isYes: false)
   }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        proceedWithAnswer(isCorrect: isCorrect )
        if isCorrect {
            correctAnswers += 1
        }
        
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
       
       DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
           guard let self = self else { return }
           self.proceedToNextQuestionOrResults()
           self.viewController?.deleteBorderImage()
       }
   }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.show(quiz: viewModel)
            }
        }
    
     func completion() {
        resetQuestionIndex()
        questionFactory?.requestNextQuestion()
        questionFactory?.loadData()
    }
    
    func proceedToNextQuestionOrResults() {
       
       if isLastQuestion() {
           viewController?.showResult(quiz: makeResultsMessage())
       } else {
          switchToNextQuestion()
          questionFactory?.requestNextQuestion()
           viewController?.makeEnableButton()
       }
   }
    
    
    func makeResultsMessage() -> QuizResultsViewModel? {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        guard let gameCount = statisticService?.gamesCount,
              let totalAccuracy = statisticService?.totalAccuracy,
              let bestGameModel = statisticService?.bestGame else {
            return nil
        }
        
        let correctBestGame = bestGameModel.correct
        let totalBestGame = bestGameModel.total
        let dataBestGame = bestGameModel.date
        
        let resultQuiz = QuizResultsViewModel(title: "Этот раунд окончен!",
                                              text:  """
                                              Ваш результат: \(correctAnswers)/10\n Количество сыграных квизов \(gameCount)
                                              Рекорд: \(correctBestGame)/\(totalBestGame) (\(dataBestGame.dateTimeString))
                                              Средняя точность: \(String(format: "%.2f", totalAccuracy))%
                                              """, buttonText: "Сыграть еще раз")
        
        return resultQuiz
    }
}
