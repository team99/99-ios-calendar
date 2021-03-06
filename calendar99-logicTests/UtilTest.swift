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
  public func test_createWeekdayRange_shouldWork() {
    for firstWeekday in 0...7 {
      let range = NNCalendarLogic.Util.weekdayRange(firstWeekday, 7)
      XCTAssertEqual(Set(range).count, range.count)
      XCTAssertTrue(range.all({$0 <= 7}))

      for index in 0...6 {
        let weekday = NNCalendarLogic.Util.weekdayWithIndex(index, firstWeekday)
        XCTAssertEqual(weekday, range[index])
      }
    }
  }

  public func test_getAvailableMonthsForMinAndMax_shouldWork() {
    let min1 = NNCalendarLogic.Month(1, 2018)
    let max1 = NNCalendarLogic.Month(8, 2017)
    XCTAssertEqual(NNCalendarLogic.Util.monthRange(min1, max1).count, 0)

    let min2 = NNCalendarLogic.Month(1, 2018)
    let max2 = NNCalendarLogic.Month(1, 2018)
    XCTAssertEqual(NNCalendarLogic.Util.monthRange(min2, max2).count, 1)

    let min3 = NNCalendarLogic.Month(1, 2018)
    let max3 = NNCalendarLogic.Month(4, 2018)
    XCTAssertEqual(NNCalendarLogic.Util.monthRange(min3, max3).count, 4)
  }

  public func test_getAvailableMonths_shouldWork() {
    let min1 = NNCalendarLogic.Month(1, 2018)
    let max1 = NNCalendarLogic.Month(2, 2017)
    XCTAssertEqual(NNCalendarLogic.Util.monthCount(min1, max1), 0)

    let min2 = NNCalendarLogic.Month(1, 2018)
    let max2 = NNCalendarLogic.Month(1, 2018)
    XCTAssertEqual(NNCalendarLogic.Util.monthCount(min2, max2), 1)

    let min3 = NNCalendarLogic.Month(1, 2018)
    let max3 = NNCalendarLogic.Month(10, 2018)
    XCTAssertEqual(NNCalendarLogic.Util.monthCount(min3, max3), 10)
  }

  public func test_calculateHighlightParts_shouldWork() {
    /// Setup
    let firstWeekday = 1
    let calendar = Calendar.current
    let times = 5
    let startDate = Date()
    let select1 = (0..<times).map({calendar.date(byAdding: .day, value: $0, to: startDate)!})
    let select2 = [startDate]
    let set1 = Set(select1.map({NNCalendarLogic.DateSelection($0, firstWeekday)}))
    let set2 = Set(select2.map({NNCalendarLogic.DateSelection($0, firstWeekday)}))

    /// When
    let p0 = NNCalendarLogic.Util.highlightPart(set1, select1[0])
    let p1 = NNCalendarLogic.Util.highlightPart(set1, select1[1])
    let p2 = NNCalendarLogic.Util.highlightPart(set1, select1[2])
    let p3 = NNCalendarLogic.Util.highlightPart(set1, select1[3])
    let p4 = NNCalendarLogic.Util.highlightPart(set1, select1[4])
    let p5 = NNCalendarLogic.Util.highlightPart(set2, select2[0])
    let p6 = NNCalendarLogic.Util.highlightPart([], Date.random()!)

    /// Then
    XCTAssertEqual(p0, .start)
    XCTAssertEqual(p1, .mid)
    XCTAssertEqual(p2, .mid)
    XCTAssertEqual(p3, .mid)
    XCTAssertEqual(p4, .end)
    XCTAssertEqual(p5, .startAndEnd)
    XCTAssertEqual(p6, .none)
  }

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
      let connected = NNCalendarLogic.Util.connectSelection(selections)
      let connectedMin = connected.min()!, connectedMax = connected.max()!
      XCTAssertEqual(connectedMin, min)
      XCTAssertEqual(connectedMax, max)
    }

    XCTAssertTrue(NNCalendarLogic.Util.connectSelection([]).isEmpty)
    XCTAssertEqual(NNCalendarLogic.Util.connectSelection([Date.random()!]).count, 1)
  }
}
