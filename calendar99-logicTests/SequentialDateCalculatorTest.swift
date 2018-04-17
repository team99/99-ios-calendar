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
  fileprivate var firstWeekDay: Int!
  fileprivate var rowCount: Int!
  fileprivate var columnCount: Int!

  override public func setUp() {
    super.setUp()
    rowCount = 6
    columnCount = 7
    dayCount = 42
    firstWeekDay = 2

    calculator = NNCalendar.DateCalculator
      .Sequential(rowCount!, columnCount!, firstWeekDay!)
  }

  public func test_calculateDayRange_shouldWork() {
    /// Setup
    var month = NNCalendar.Month(Date())

    /// When
    for _ in 0..<iterations! {
      let range = calculator.calculateDateRange(month)
      month = month.with(monthOffset: 1)!

      /// Then
      let firstDate = range.first!
      let weekdayComp = Calendar.current.component(.weekday, from: firstDate)
      XCTAssertEqual(range.count, dayCount!)
      XCTAssertEqual(weekdayComp, firstWeekDay!)

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
    var month = NNCalendar.Month(Date())

    for ix in 0..<200 {
      var prevDate: Date?

      /// When
      for jx in 0..<iterations! {
        let date = calculator.calculateDateWithOffset(month, jx)!

        if let prevDate = prevDate {
          let diff = date.timeIntervalSince(prevDate) / 60 / 60 / 24
          XCTAssertEqual(diff, 1)
        }

        prevDate = date
      }

      month = month.with(monthOffset: ix)!
    }
  }

  public func test_calculateMultiMonthGridSelections_shouldWork() {
    /// Setup
    let firstMonth = NNCalendar.Month(Date())
    let allMonths = (0..<100).map({firstMonth.with(monthOffset: $0)!})
    let months = allMonths.map({NNCalendar.MonthComp($0, dayCount!)})
    var prevSelect = Set<Date>()

    /// When
    for _ in 0..<iterations! {
      let selectionCount = Int.random(10, 20)

      let currentSelect = Set((0..<selectionCount)
        .map({(_) -> Date in
          let month = months.randomElement()!
          let dayIndex = Int.random(0, month.dayCount)
          return calculator.calculateDateWithOffset(month.month, dayIndex)!
        }))

      let changedSelect = calculator.extractChanges(prevSelect, currentSelect)

      let gridSelections = calculator.calculateGridSelectionChanges(
          months, prevSelect, currentSelect)

      /// Then
      for gridSelection in gridSelections {
        let selectedMonth = months[gridSelection.monthIndex].month

        let selectedDate = calculator.calculateDateWithOffset(
          selectedMonth,
          gridSelection.dayIndex)!

        XCTAssertTrue(changedSelect.contains(selectedDate))
      }

      prevSelect = currentSelect
    }
  }

  public func test_calculateSingleMonthGridSelection_shouldWork() {
    /// Setup
    var currentMonth = NNCalendar.Month(Date())
    var prevSelect = Set<Date>()

    /// When
    for i in 0..<iterations! {
      let currentMonthComp = NNCalendar.MonthComp(currentMonth, dayCount!)
      let selectionCount = Int.random(1, dayCount!)

      let currentSelect = Set((0..<selectionCount).map({
        calculator.calculateDateWithOffset(currentMonth, $0)!
      }))

      let changedSelect = calculator.extractChanges(prevSelect, currentSelect)

      let gridSelections = calculator.calculateGridSelectionChanges(
        currentMonthComp, prevSelect, currentSelect)

      /// Then
      for gridSelection in gridSelections {

        // The month index is not necessarily the same as the month value in the
        // current month value, because we calculate for the previous and next
        // months as well.
        if gridSelection.monthIndex == currentMonth.month {
          let selectedDate = calculator.calculateDateWithOffset(
            currentMonth,
            gridSelection.dayIndex)!

          XCTAssertTrue(changedSelect.contains(selectedDate))
        }
      }

      currentMonth = currentMonth.with(monthOffset: i)!
      prevSelect = currentSelect
    }
  }

  public func test_calculateHighlightPoss_shouldWork() {
    /// Setup
    let calendar = Calendar.current
    let times = 5
    let startDate = Date()
    let select1 = (0..<times).map({calendar.date(byAdding: .day, value: $0, to: startDate)!})
    let select2 = [startDate]
    let set1 = Set(select1)
    let set2 = Set(select2)

    /// When
    let p0 = calculator.calculateHighlightPos(set1, select1[0])
    let p1 = calculator.calculateHighlightPos(set1, select1[1])
    let p2 = calculator.calculateHighlightPos(set1, select1[2])
    let p3 = calculator.calculateHighlightPos(set1, select1[3])
    let p4 = calculator.calculateHighlightPos(set1, select1[4])
    let p5 = calculator.calculateHighlightPos(set2, select2[0])

    /// Then
    XCTAssertEqual(p0, .start)
    XCTAssertEqual(p1, .mid)
    XCTAssertEqual(p2, .mid)
    XCTAssertEqual(p3, .mid)
    XCTAssertEqual(p4, .end)
    XCTAssertEqual(p5, .startAndEnd)
  }
}
