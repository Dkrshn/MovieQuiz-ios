import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    
    
    // MARK: - Lifecycle
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        makeDisEnableButton()
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        makeDisEnableButton()
        presenter.noButtonClicked()
        
    }
    
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(viewController: self)
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    
     func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func deleteBorderImage() {
        imageView.layer.borderWidth = 0
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
    

    func showResult(quiz result: QuizResultsViewModel?) {
        guard let resultQuiz = result else {
            return
        }
        let alertResults = AlertModel(title: resultQuiz.title, massage: resultQuiz.text, buttonText: resultQuiz.buttonText, completion: presenter.completion)
        alertPresenter?.showAlert(result: alertResults)
        makeEnableButton()
    }
    
    
     func makeEnableButton() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    private func makeDisEnableButton() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func showLoadingIndicator() {
        
        activityIndicator.startAnimating()
    }
    
   func hideLoadingIndicator() {
        
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка", massage: message,
                               buttonText: "Попробовать еще раз", completion: presenter.completion)
        let alert = UIAlertController(title: model.title, message: model.massage, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: { _ in
            model.completion()
        })
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}
