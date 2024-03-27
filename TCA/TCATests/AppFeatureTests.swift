//
//  AppFeatureTests.swift
//  TCATests
//
//  Created by Trevor Walker on 3/26/24.
//

import XCTest
import ComposableArchitecture
@testable import TCA

@MainActor
final class AppFeatureTests: XCTestCase {
  func testIncrementFirstTab() async {
    let store = TestStore(initialState: AppFeature.State(),
                          reducer: { AppFeature() })

    await store.send(\.tab1.incrementButtonTapped) {
      $0.tab1.count = 1
    }
  }
}
