//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Даниил Крашенинников on 29.12.2022.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        
        app.buttons["Yes"].tap()
        
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        
        sleep(3)
        
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
        

    }
    
    func testNoButton() {
        
        let firstPoster = app.images["Poster"]
        
        app.buttons["No"].tap()
        
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        
        sleep(3)
        
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
        

    }

    func testFinishAlert() {
        
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let finishAlert = app.alerts["Finish Alert"]
    
        XCTAssertTrue(finishAlert.exists)
        XCTAssertEqual(finishAlert.label, "Этот раунд окончен!")
        XCTAssertTrue(finishAlert.buttons.firstMatch.label == "Сыграть еще раз")
    }
    
    func testAlertDismiss() {
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let finishAlert = app.alerts["Finish Alert"]
        let indexLabel = app.staticTexts["Index"]
        finishAlert.buttons.firstMatch.tap()
        
        sleep(2)
        
        XCTAssertFalse(finishAlert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
        
        
    }

}
