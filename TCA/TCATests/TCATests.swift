//
//  TCATests.swift
//  TCATests
//
//  Created by Trevor Walker on 3/26/24.
//

import XCTest
@testable import TCA
import ComposableArchitecture

@MainActor
final class TCATests: XCTestCase {

  func testCounter() async {
    let store = TestStore(initialState: CounterFeature.State(),
                          reducer: { CounterFeature() })

    await store.send(.incrementButtonTapped) {
      $0.count = 1
    }

    await store.send(.decrementButtonTapped) {
      $0.count = 0
    }
  }

  func testTimer() async {
    let clock = TestClock()
    let store = TestStore(initialState: CounterFeature.State(),
                          reducer: { CounterFeature() },
                          withDependencies: { $0.continuousClock = clock })


    await store.send(.toggleTimerButtonTapped) {
      $0.isTimerRunning = true
    }

    await clock.advance(by: .seconds(1))
    await store.receive(\.timerTick) {
      $0.count = 1
    }

    await store.send(.toggleTimerButtonTapped) {
      $0.isTimerRunning = false
    }
  }

  func testNumberFact() async {
    let store = TestStore(initialState: CounterFeature.State(),
                          reducer: { CounterFeature() },
                          withDependencies: { $0.numberFact.fetch = { "\($0) is a good number" } })

    await store.send(.factButtonTapped) {
      $0.isLoading = true
    }

    await store.receive(\.factResponse) {
      $0.isLoading = false
      $0.fact = "0 is a good number"
    }
  }
}
