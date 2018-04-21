//
//  DefaultDateCalculatorTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftUtilities
import XCTest
@testable import calendar99_logic

/// Tests for date calculator.
public final class DefaultDateCalculatorTest: RootTest {
  fileprivate var calculator: NNCalendar.DateCalc.Default!
  fileprivate var dayCount: Int!
  fileprivate var firstWeekDay: Int!
  fileprivate var weekdayStacks: Int!

  override public func setUp() {
    super.setUp()
    iterations = 1000
    weekdayStacks = 6
    dayCount = 42
    firstWeekDay = 2
    calculator = NNCalendar.DateCalc.Default(weekdayStacks!, firstWeekDay!)
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
          return NNCalendar.Util.dateWithOffset(month.month, firstWeekday, dayIndex)!
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

        let selectedDate = NNCalendar.Util
          .dateWithOffset(selectedMonth, firstWeekday, position.dayIndex)!

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
        .map({NNCalendar.Util.dateWithOffset(currentMonth, firstWeekday, $0)!})
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
          let selectedDate = NNCalendar.Util
            .dateWithOffset(currentMonth, firstWeekday, position.dayIndex)!

          XCTAssertTrue(changed.contains(where: {$0.contains(selectedDate)}))
        }
      }

      currentMonth = currentMonth.with(monthOffset: i)!
      prevSelect = currentSelect
    }
  }
}
