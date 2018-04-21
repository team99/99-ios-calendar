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
  fileprivate var calculator: NNCalendar.DateCalc.Sequential!
  fileprivate var dayCount: Int!
  fileprivate var firstWeekDay: Int!
  fileprivate var weekdayStacks: Int!

  override public func setUp() {
    super.setUp()
    iterations = 1000
    weekdayStacks = 6
    dayCount = 42
    firstWeekDay = 2
    calculator = NNCalendar.DateCalc.Sequential(weekdayStacks!, firstWeekDay!)
  }

  public func test_calculateDayRange_shouldWork() {
    /// Setup
    var month = NNCalendar.Month(Date())

    /// When
    for _ in 0..<iterations! {
      let range = calculator.dateRange(month)
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
        let date = calculator.dateWithOffset(month, jx)!

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
    let firstWeekday = calculator!.firstWeekday
    let firstMonth = NNCalendar.Month(Date())
    let allMonths = (0..<100).map({firstMonth.with(monthOffset: $0)!})
    let monthComps = allMonths.map({NNCalendar.MonthComp($0, dayCount!, firstWeekday)})
    var prevSelections = Set<NNCalendar.Selection>()

    /// When
    for _ in 0..<iterations! {
      let selectionCount = Int.random(10, 20)
      let currentMonth = monthComps.randomElement()!.month

      let currentSelections = Set((0..<selectionCount)
        .map({(_) -> Date in
          let month = monthComps.randomElement()!
          let dayIndex = Int.random(0, month.dayCount)
          return calculator.dateWithOffset(month.month, dayIndex)!
        })
        .map({NNCalendar.DateSelection($0, firstWeekday)})
        .map({$0 as NNCalendar.Selection}))

      let changedSelect = calculator.extractChanges(prevSelections, currentSelections)

      let gridPositions = calculator.gridSelectionChanges(
        monthComps, currentMonth,
        prevSelections,
        currentSelections)

      /// Then
      for position in gridPositions {
        let selectedMonth = monthComps[position.monthIndex].month
        let selectedDate = calculator.dateWithOffset(selectedMonth, position.dayIndex)!
        XCTAssertTrue(changedSelect.contains(where: {$0.contains(selectedDate)}))
      }

      prevSelections = currentSelections
    }
  }

  public func test_calculateSingleMonthGridSelection_shouldWork() {
    /// Setup
    let firstWeekday = calculator!.firstWeekday
    var currentMonth = NNCalendar.Month(Date())
    var prevSelect = Set<NNCalendar.Selection>()

    /// When
    for i in 0..<iterations! {
      let currentComp = NNCalendar.MonthComp(currentMonth, dayCount!, firstWeekday)
      let selectionCount = Int.random(1, dayCount!)

      let currentSelect = Set((0..<selectionCount)
        .map({calculator.dateWithOffset(currentMonth, $0)!})
        .map({NNCalendar.DateSelection($0, firstWeekday)})
        .map({$0 as NNCalendar.Selection}))

      let changed = calculator.extractChanges(prevSelect, currentSelect)

      let gridPositions = calculator
        .gridSelectionChanges(currentComp, prevSelect, currentSelect)

      /// Then
      for position in gridPositions {

        // The month index is not necessarily the same as the month value in the
        // current month value, because we calculate for the previous and next
        // months as well.
        if position.monthIndex == currentMonth.month {
          let selectedDate = calculator.dateWithOffset(
            currentMonth, position.dayIndex)!

          XCTAssertTrue(changed.contains(where: {$0.contains(selectedDate)}))
        }
      }

      currentMonth = currentMonth.with(monthOffset: i)!
      prevSelect = currentSelect
    }
  }
}
