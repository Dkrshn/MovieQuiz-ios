//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Даниил Крашенинников on 30.11.2022.
//

import Foundation
 
struct AlertModel {
    let title: String
    let massage: String
    let buttonText: String
    let completion: (() -> Void)
}
