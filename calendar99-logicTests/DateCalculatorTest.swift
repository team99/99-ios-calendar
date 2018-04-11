//
//  DateCalculatorTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import calendar99_logic

/// Tests for date calculator.
public final class DateCalculatorTest: XCTestCase {
  fileprivate var iterations: Int!

  override public func setUp() {
    super.setUp()
    iterations = 10000
    continueAfterFailure = false
  }

  public func test_sequentialDateCalculator_shouldWork() {
    /// Setup
    let calculator = NNCalendar.DateCalculator.Sequential()
    var components = NNCalendar.monthComponent(month: 4, year: 2018)

    /// When
    for _ in 0..<iterations! {
      let range = calculator.calculateRange(components, 1, 6, 7)

      let newMonthAndYear = NNCalendar.DateUtil
        .newMonthAndYear(components.month, components.year, 1)!

      components = NNCalendar.monthComponent(month: newMonthAndYear.month,
                                         year: newMonthAndYear.year)

      /// Then
      let firstDate = range.first!
      let weekdayComp = Calendar.current.component(.weekday, from: firstDate)
      XCTAssertEqual(range.count, 42)
      XCTAssertEqual(weekdayComp, 1)

      for (ix, date) in range.enumerated() {
        if ix != range.count - 1 {
          let nextDate = range[ix + 1]
          let difference = nextDate.timeIntervalSince(date)
          let dateDifference = difference / 60 / 60 / 24
          XCTAssertEqual(dateDifference, 1)
        }
      }
    }
  }
}
