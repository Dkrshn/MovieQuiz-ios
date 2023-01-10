//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Даниил Крашенинников on 27.12.2022.
//

import Foundation
import XCTest

@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    
    func testSuccessLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        let moviesLoader = MoviesLoader(networkClient: stubNetworkClient)
        
        //When
        let expectation = expectation(description: "Loading expectation")
        
        moviesLoader.loadMovies(handler: {result in
            // Then
            switch result {
            case .success(let mostPopularMovies):
                XCTAssertEqual(mostPopularMovies.items.count, 2)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Unexpected failure")
            }
        })
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let moviesLoader = MoviesLoader(networkClient: stubNetworkClient)
        
        //When
        let expectation = expectation(description: "Loading expectation")
        
        moviesLoader.loadMovies(handler: {result in
            // Then
            switch result {
            case .success(let mostPopularMovies):
                XCTFail("Unexpected success")
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        })
        waitForExpectations(timeout: 1)
    }
}
