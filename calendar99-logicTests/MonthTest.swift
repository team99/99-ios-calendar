//
//  MonthTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftUtilities
import XCTest
@testable import calendar99_logic

/// Tests for months.
public final class MonthTest: RootTest {
  override public func setUp() {
    super.setUp()

    // Since these tests do not require any waiting, might as well be ludicrous
    // with the iteration count.
    iterations = 20000
  }

  public func test_newMonthWithMonthOffset_shouldWork() {
    /// Setup
    var date = Date()
    var month = NNCalendar.Month(date)

    /// When
    for _ in 0..<iterations! {
      let newMonth = month.with(monthOffset: 1)!
      let dateComponents = newMonth.dateComponents()
      let newDate = Calendar.current.date(from: dateComponents)!
      let oldDate = date
      date = newDate
      month = newMonth

      /// Then
      XCTAssertGreaterThan(newDate, oldDate)
    }
  }

  public func test_checkContainDate_shouldWork() {
    /// Setup
    let calendar = Calendar.current
    let date = Date()
    let firstMonth = NNCalendar.Month(date)

    /// When
    for i in 0..<iterations! {
      let newComp = firstMonth.with(monthOffset: i)!
      let dateOffset = Int.random(0, 40)
      let newDate = calendar.date(byAdding: .day, value: dateOffset, to: date)!

      /// Then
      let newMonthForDate = NNCalendar.Month(newDate)

      if newComp.contains(newDate) {
        XCTAssertEqual(newComp, newMonthForDate)
      } else {
        XCTAssertNotEqual(newComp, newMonthForDate)
      }
    }
  }

  public func test_getDatesWithWeekday_shouldWork() {
    /// Setup
    let calendar = Calendar.current
    let firstMonth = NNCalendar.Month(Date())

    /// When
    for i in 0..<iterations! {
      let month = firstMonth.with(monthOffset: i)!

      for weekday in 1...7 {
        let dates = month.datesWithWeekday(weekday)

        /// Then
        for date in dates {
          let weekdayComp = calendar.component(.weekday, from: date)
          XCTAssertEqual(weekdayComp, weekday)
          XCTAssertEqual(NNCalendar.Month(date), month)
        }
      }
    }
  }
}
