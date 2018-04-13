//
//  MonthCompTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftUtilities
import XCTest
@testable import calendar99_logic

/// Month comp tests.
public final class MonthCompTest: XCTestCase {
  fileprivate var iterations: Int?

  override public func setUp() {
    super.setUp()
    iterations = 10000
  }

  public func test_newMonthCompWithMonthOffset_shouldWork() {
    /// Setup
    var date = Date()
    var components = NNCalendar.MonthComp(date)

    /// When
    for _ in 0..<iterations! {
      let newComps = components.with(monthOffset: 1)!
      let dateComponents = newComps.dateComponents()
      let newDate = Calendar.current.date(from: dateComponents)!
      let oldDate = date
      date = newDate
      components = newComps

      /// Then
      XCTAssertGreaterThan(newDate, oldDate)
    }
  }

  public func test_checkContainDate_shouldWork() {
    /// Setup
    let calendar = Calendar.current
    let date = Date()
    let firstComp = NNCalendar.MonthComp(date)

    /// When
    for i in 0..<iterations! {
      let newComp = firstComp.with(monthOffset: i)!
      let dateOffset = Int.random(0, 40)
      let newDate = calendar.date(byAdding: .day, value: dateOffset, to: date)!

      /// Then
      let newDateMonthComp = NNCalendar.MonthComp(newDate)

      if newComp.contains(newDate) {
        XCTAssertEqual(newComp, newDateMonthComp)
      } else {
        XCTAssertNotEqual(newComp, newDateMonthComp)
      }
    }
  }
}
