//
//  SequentialDateCalculatorTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import calendar99_logic

/// Tests for date calculator.
public final class SequentialDateCalculatorTest: XCTestCase {
  fileprivate var calculator: NNCalendar.DateCalculator.Sequential!
  fileprivate var currentMonthComp: NNCalendar.MonthComp!
  fileprivate var iterations: Int!

  override public func setUp() {
    super.setUp()
    calculator = NNCalendar.DateCalculator.Sequential()
    currentMonthComp = NNCalendar.MonthComp(month: 4, year: 2018)
    iterations = 1000
    continueAfterFailure = false
  }

  public func test_calculateDayRange_shouldWork() {
    /// Setup & When
    for _ in 0..<iterations! {
      let range = calculator.calculateDateRange(currentMonthComp, 1, 6, 7)
      currentMonthComp = NNCalendar.DateUtil.newMonthComp(currentMonthComp, 1)!

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

  public func test_calculateDateWithOffset_shouldWork() {
    /// Setup
    var monthComp = currentMonthComp!

    for ix in 0..<100 {
      var prevDate: Date?

      /// When
      for jx in 0..<iterations! {
        let date = calculator.calculateDateWithOffset(monthComp, 1, jx)!

        if let prevDate = prevDate {
          let diff = date.timeIntervalSince(prevDate) / 60 / 60 / 24
          XCTAssertEqual(diff, 1)
        }

        prevDate = date
      }

      monthComp = NNCalendar.DateUtil.newMonthComp(monthComp, ix)!
    }
  }

  public func test_calculateGridSelections_shouldWork() {
    /// Setup

    /// When

    /// Then
  }
}
