//
//  SequentialDateCalculatorTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftUtilities
import XCTest
@testable import calendar99_logic

/// Tests for date calculator.
public final class SequentialDateCalculatorTest: RootTest {
  fileprivate var calculator: NNCalendar.DateCalculator.Sequential!
  fileprivate var dayCount: Int!

  override public func setUp() {
    super.setUp()
    calculator = NNCalendar.DateCalculator.Sequential()
    dayCount = 42
    continueAfterFailure = false
  }

  public func test_calculateDayRange_shouldWork() {
    /// Setup
    var monthComp = NNCalendar.MonthComp(Date())

    /// When
    for _ in 0..<iterations! {
      let range = calculator.calculateDateRange(monthComp, firstDayOfWeek!, 6, 7)
      monthComp = monthComp.with(monthOffset: 1)!

      /// Then
      let firstDate = range.first!
      let weekdayComp = Calendar.current.component(.weekday, from: firstDate)
      XCTAssertEqual(range.count, dayCount!)
      XCTAssertEqual(weekdayComp, firstDayOfWeek!)

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
    var monthComp = NNCalendar.MonthComp(Date())

    for ix in 0..<200 {
      var prevDate: Date?

      /// When
      for jx in 0..<iterations! {
        let date = calculator.calculateDateWithOffset(monthComp, firstDayOfWeek!, jx)!

        if let prevDate = prevDate {
          let diff = date.timeIntervalSince(prevDate) / 60 / 60 / 24
          XCTAssertEqual(diff, 1)
        }

        prevDate = date
      }

      monthComp = monthComp.with(monthOffset: ix)!
    }
  }

  public func test_calculateMultiMonthGridSelections_shouldWork() {
    /// Setup
    let firstComp = NNCalendar.MonthComp(Date())
    let monthComps = (0..<100).map({firstComp.with(monthOffset: $0)!})
    let months = monthComps.map({NNCalendar.Month($0, dayCount!)})
    var prevSelect = Set<Date>()

    /// When
    for _ in 0..<iterations! {
      let selectionCount = Int.random(10, 20)

      let currentSelect = Set((0..<selectionCount)
        .map({(_) -> Date in
          let month = months.randomElement()!
          let dayIndex = Int.random(0, month.dayCount)
          return calculator.calculateDateWithOffset(month.monthComp, 1, dayIndex)!
        }))

      let changedSelect = calculator.extractChanges(prevSelect, currentSelect)

      let gridSelections = calculator.calculateGridSelection(
          months,
          firstDayOfWeek!,
          prevSelect,
          currentSelect
      )

      /// Then
      for gridSelection in gridSelections {
        let selectedMonth = months[gridSelection.monthIndex].monthComp

        let selectedDate = calculator.calculateDateWithOffset(
          selectedMonth,
          firstDayOfWeek!,
          gridSelection.dayIndex
        )!

        XCTAssertTrue(changedSelect.contains(selectedDate))
      }

      prevSelect = currentSelect
    }
  }

  public func test_calculateSingleMonthGridSelection_shouldWork() {
    /// Setup
    var currentComp = NNCalendar.MonthComp(Date())
    var prevSelect = Set<Date>()

    /// When
    for i in 0..<iterations! {
      let currentMonth = NNCalendar.Month(currentComp, dayCount!)
      let selectionCount = Int.random(1, dayCount!)

      let currentSelect = Set((0..<selectionCount).map({
        calculator.calculateDateWithOffset(currentComp, firstDayOfWeek!, $0)!
      }))

      let changedSelect = calculator.extractChanges(prevSelect, currentSelect)

      let gridSelections = calculator.calculateGridSelection(
        currentMonth,
        firstDayOfWeek!,
        prevSelect,
        currentSelect
      )

      /// Then
      for gridSelection in gridSelections {

        // The month index is not necessary the same as the month in the current
        // month comp, because we calculate for the previous and next months as
        // well.
        if gridSelection.monthIndex == currentComp.month {
          let selectedDate = calculator.calculateDateWithOffset(
            currentComp,
            firstDayOfWeek!,
            gridSelection.dayIndex
          )!

          XCTAssertTrue(changedSelect.contains(selectedDate))
        }
      }

      currentComp = currentComp.with(monthOffset: i)!
      prevSelect = currentSelect
    }
  }
}
