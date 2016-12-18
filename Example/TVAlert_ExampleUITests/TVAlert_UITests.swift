//
//  TVAlert_ExampleUITests.swift
//  TVAlert_ExampleUITests
//
//  Created by Austin Drummond on 12/17/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

class TVAlert_ExampleUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.children(matching: .cell).element(boundBy: 3).staticTexts["Simple"].tap()
        
        let okButton = app.buttons["OK"]
        okButton.tap()
        tablesQuery.children(matching: .cell).element(boundBy: 4).staticTexts["Multibutton"].tap()
        
        let destroyButton = app.buttons["Destroy"]
        destroyButton.tap()
        
        let loginStaticText = tablesQuery.children(matching: .cell).element(boundBy: 5).staticTexts["Login"]
        loginStaticText.tap()
        
        let loginTextField = app.textFields["Login"]
        loginTextField.tap()
        loginTextField.typeText("Username")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Password")
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element(boundBy: 1).children(matching: .other).element.tap()
        app.buttons["Login"].tap()
        loginStaticText.tap()
        
    }
    
}
