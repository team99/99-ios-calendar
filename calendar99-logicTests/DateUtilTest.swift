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
    var month = Calendar.current.component(.month, from: date)
    var year = Calendar.current.component(.year, from: date)

    /// When
    for _ in 0..<iterations! {
      let newMonthAndYear = Calendar99.DateUtil.newMonthAndYear(month, year, 1)
      month = newMonthAndYear!.month
      year = newMonthAndYear!.year
      var components = DateComponents()
      components.setValue(month, for: .month)
      components.setValue(year, for: .year)
      let newDate = Calendar.current.date(from: components)!
      let oldDate = date
      date = newDate

      /// Then
      XCTAssertGreaterThan(newDate, oldDate)
    }
  }
}
