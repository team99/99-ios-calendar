//
//  UtilTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 18/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftUtilities
import XCTest
@testable import calendar99_logic

public final class UtilTest: RootTest {
  override public func setUp() {
    super.setUp()
  }
}

public extension UtilTest {
  public func test_connectSelection_shouldWork() {
    /// Setup
    iterations = 500
    let calendar = Calendar.current
    let selectionCount = 5

    /// When
    for _ in 0..<iterations! {
      // Strip all hour/minute/second to ensure the date does not flow over to
      // the next day.
      let selections = (0..<selectionCount).map({_ -> Date in
        let date = Date.random()!
        let comps = calendar.dateComponents([.day, .month, .year], from: date)
        return calendar.date(from: comps)!
      })

      let min = selections.min()!, max = selections.max()!
      let connected = NNCalendar.Util.connectSelection(selections)
      let connectedMin = connected.min()!, connectedMax = connected.max()!
      XCTAssertEqual(connectedMin, min)
      XCTAssertEqual(connectedMax, max)
    }

    XCTAssertTrue(NNCalendar.Util.connectSelection([]).isEmpty)
    XCTAssertEqual(NNCalendar.Util.connectSelection([Date.random()!]).count, 1)
  }
}
