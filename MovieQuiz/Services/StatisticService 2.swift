//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Даниил Крашенинников on 06.12.2022.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    
    private let userDefaults = UserDefaults.standard
   
    private (set) var countCorrectAnswers: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.correct.rawValue),
                  let record = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }
            userDefaults.set(data, forKey: Keys.correct.rawValue)
        }
    }
    
    private (set) var totalQuestions: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let record = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    
    
     var totalAccuracy: Double {
        get {
            return (Double(self.countCorrectAnswers) / Double(self.totalQuestions)) * 100
        }
    }
    
    
   private(set) var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let record = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            return record
        }
        set {
            let currentCount = newValue
            guard let data = try? JSONEncoder().encode(currentCount) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    private(set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        countCorrectAnswers += count
        totalQuestions += amount
        if bestGame.compareRecord(current: count) {
            let currentGame = GameRecord(correct: count, total: amount, date: Date())
            bestGame = currentGame
        }
    }
}
    
    struct GameRecord: Codable {
        let correct: Int
        let total: Int
        let date: Date
         
        func compareRecord (current currentCorrect: Int) -> Bool {
                correct < currentCorrect
            }
        
        }

