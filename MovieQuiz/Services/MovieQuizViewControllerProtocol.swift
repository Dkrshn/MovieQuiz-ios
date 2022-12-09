//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Даниил Крашенинников on 06.01.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
        func show(quiz step: QuizStepViewModel)
        func showResult(quiz result: QuizResultsViewModel?)
        
        func highlightImageBorder(isCorrectAnswer: Bool)
        
        func showLoadingIndicator()
        func hideLoadingIndicator()
        func deleteBorderImage()
        func makeEnableButton()
        
        func showNetworkError(message: String)
}
