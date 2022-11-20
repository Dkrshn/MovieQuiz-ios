//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Даниил Крашенинников on 30.11.2022.
//

import Foundation
import UIKit

struct AlertPresenter: AlertPresenterProtocol {
    
   private weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func showAlert(result: AlertModel) {
        let alert = UIAlertController(title: result.title, message: result.massage, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default, handler: { _ in
            result.completion()
            
        })
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}


