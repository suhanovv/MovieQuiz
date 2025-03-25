//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Вадим Суханов on 01.03.2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testTapYesButtonChangeIndexLabel() {
        sleep(10)
        
        app.buttons["Yes"].tap()
        
        sleep(5)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testTapNoButtonChangeIndexLabel() {
        sleep(10)
        
        app.buttons["No"].tap()
        
        sleep(5)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testEndRoundAlertAppearing() {
        sleep(3)
        
        for _ in 1...10 {
            sleep(3)
            app.buttons["Yes"].tap()
        }
        
        sleep(3)
        let alert = app.alerts["Этот раунд окончен!"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
        
    }
    
    func testEndRoundAlertTapButton() {
        sleep(3)
        
        for _ in 1...10 {
            sleep(3)
            app.buttons["Yes"].tap()
        }
        
        sleep(3)
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.exists)
        
        alert.buttons.firstMatch.tap()
        
        sleep(3)
        XCTAssertFalse(app.alerts["Этот раунд окончен!"].exists)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")

        
    }

}
