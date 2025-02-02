//
//  AlertModal.swift
//  MovieQuiz
//
//  Created by Вадим Суханов on 26.01.2025.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void  
}
