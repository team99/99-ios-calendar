//
//  SelectionTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 19/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import calendar99_logic

/// Tests for selection object.
public final class SelectionTest: RootTest {}

public extension SelectionTest {
  public func test_defaultSelection_shouldWorkd() {
    /// Setup
    let selection1 = NNCalendarLogic.Selection()
    let selection2 = NNCalendarLogic.Selection()

    /// When & Then
    XCTAssertEqual(selection1, selection2)
    XCTAssertEqual(selection1.hashValue, selection2.hashValue)

    XCTAssertEqual(selection1.contains(Date.random()!),
                   selection2.contains(Date.random()!))

    XCTAssertEqual(selection1.gridPosition([], 0),
                   selection2.gridPosition([], 0))
  }

  public func test_repeatWeekdaySelection_shouldWork() {
    /// Setup
    let calendar = Calendar.current
    let firstWeekday = 1

    /// When
    for _ in 0..<iterations! {
      let month = NNCalendarLogic.Month(Date.random()!)

      let monthComps = (0..<100)
        .map({month.with(monthOffset: $0)!})
        .map({NNCalendarLogic.MonthComp($0, 42, 1)})

      for weekday in 1...6 {
        let weekday1 = weekday
        let weekday2 = weekday + 1
        let s1 = NNCalendarLogic.RepeatWeekdaySelection(weekday1, firstWeekday)
        let s2 = NNCalendarLogic.RepeatWeekdaySelection(weekday2, firstWeekday)
        let date1 = NNCalendarLogic.Util.firstDateWithWeekday(month, weekday1)!
        let date2 = NNCalendarLogic.Util.firstDateWithWeekday(month, weekday2)!
        let position1 = s1.gridPosition(monthComps, 0)
        let position2 = s2.gridPosition(monthComps, 0)

        /// Then
        XCTAssertNotEqual(s1, s2)
        XCTAssertTrue(s1.contains(date1))
        XCTAssertFalse(s2.contains(date1))
        XCTAssertTrue(s2.contains(date2))
        XCTAssertFalse(s1.contains(date2))

        for p1 in position1 {
          let monthComp = monthComps[p1.monthIndex]
          let dateAtP1 = monthComp.dateAtIndex(p1.dayIndex)!
          XCTAssertEqual(calendar.component(.weekday, from: dateAtP1), weekday1)
        }

        for p2 in position2 {
          let monthComp = monthComps[p2.monthIndex]
          let dateAtP2 = monthComp.dateAtIndex(p2.dayIndex)!
          XCTAssertEqual(calendar.component(.weekday, from: dateAtP2), weekday2)
        }

        XCTAssertTrue(s1.gridPosition(monthComps, -1).isEmpty)
        XCTAssertTrue(s1.gridPosition(monthComps, monthComps.count + 1).isEmpty)
      }
    }
  }
}
