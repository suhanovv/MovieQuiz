//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Вадим Суханов on 26.01.2025.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {

    weak private var controller: UIViewController?
    
    init(controller: UIViewController?) {
        self.controller = controller
    }
    
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default
        ) { _ in
            alertModel.completion()
        }
        alert.addAction(action)
        controller?.present(alert, animated: true, completion: nil)
    }
    
}
