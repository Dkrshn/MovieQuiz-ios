import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Lifecycle
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        makeDisEnableButton()
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    @IBAction private func noButtonClicked(_ sender: Any) { 
        guard let currentQuestion = currentQuestion else {
            return
        }
        makeDisEnableButton()
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(viewController: self)
        questionFactory?.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
            currentQuestion = question
            let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
                    self?.show(quiz: viewModel)
        }
    }
    

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
       return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                                question: model.text,
                                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    private func showAnswerResult(isCorrect: Bool) {
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // запускаем задачу через 1 секунду
            guard let self = self else { return }
            
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
        }
        
        if isCorrect {
            correctAnswers += 1
        }
        
    }
    
    private func completion() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func showNextQuestionOrResults() {

        if currentQuestionIndex == questionsAmount - 1 {
            
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            guard let gameCount = statisticService?.gamesCount,
                  let totalAccuracy = statisticService?.totalAccuracy,
                  let bestGameModel = statisticService?.bestGame else {
                return
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
            let alertResults = AlertModel(title: resultQuiz.title, massage: resultQuiz.text, buttonText: resultQuiz.buttonText, completion: completion)
            alertPresenter?.showAlert(result: alertResults)
            makeEnableButton ()
        } else {
            makeEnableButton ()
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    private func makeEnableButton() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    private func makeDisEnableButton() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
}
