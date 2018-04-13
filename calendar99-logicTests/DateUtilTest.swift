//
//  DateUtilTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import calendar99_logic

/// Date util tests.
public final class DateUtilTest: XCTestCase {
  fileprivate var iterations: Int?

  override public func setUp() {
    super.setUp()
    iterations = 10000
  }

  public func test_newMonthAndYear_shouldWork() {
    /// Setup
    var date = Date()
    var components = NNCalendar.MonthComp(date)

    /// When
    for _ in 0..<iterations! {
      let newComps = NNCalendar.DateUtil.newMonthComp(components, 1)!
      let dateComponents = newComps.dateComponents()
      let newDate = Calendar.current.date(from: dateComponents)!
      let oldDate = date
      date = newDate
      components = newComps

      /// Then
      XCTAssertGreaterThan(newDate, oldDate)
    }
  }
}
