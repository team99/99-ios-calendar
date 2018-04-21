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
  public func test_calculateHighlightParts_shouldWork() {
    /// Setup
    let firstWeekday = 1
    let calendar = Calendar.current
    let times = 5
    let startDate = Date()
    let select1 = (0..<times).map({calendar.date(byAdding: .day, value: $0, to: startDate)!})
    let select2 = [startDate]
    let set1 = Set(select1.map({NNCalendar.DateSelection($0, firstWeekday)}))
    let set2 = Set(select2.map({NNCalendar.DateSelection($0, firstWeekday)}))

    /// When
    let p0 = NNCalendar.Util.highlightPart(set1, select1[0])
    let p1 = NNCalendar.Util.highlightPart(set1, select1[1])
    let p2 = NNCalendar.Util.highlightPart(set1, select1[2])
    let p3 = NNCalendar.Util.highlightPart(set1, select1[3])
    let p4 = NNCalendar.Util.highlightPart(set1, select1[4])
    let p5 = NNCalendar.Util.highlightPart(set2, select2[0])
    let p6 = NNCalendar.Util.highlightPart([], Date.random()!)

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
      let connected = NNCalendar.Util.connectSelection(selections)
      let connectedMin = connected.min()!, connectedMax = connected.max()!
      XCTAssertEqual(connectedMin, min)
      XCTAssertEqual(connectedMax, max)
    }

    XCTAssertTrue(NNCalendar.Util.connectSelection([]).isEmpty)
    XCTAssertEqual(NNCalendar.Util.connectSelection([Date.random()!]).count, 1)
  }
}
