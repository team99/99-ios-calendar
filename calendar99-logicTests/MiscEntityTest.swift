//
//  MiscEntityTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftUtilities
import XCTest
@testable import calendar99_logic

public final class MiscEntityTest: RootTest {
  override public func setUp() {
    super.setUp()
    iterations = 10000
  }

  public func test_dayImplementation_shouldWorkCorrectly() {
    /// Setup
    let calendar = Calendar.current

    let highlightParts = [NNCalendarLogic.HighlightPart.startAndEnd,
                          .start, .end, .mid, .none]

    /// When
    for _ in 0..<iterations {
      let isToday = Bool.random()
      let date = isToday ? Date() : Date.random()!
      let dateComponent = calendar.component(.day, from: date)
      let description = String(dateComponent)
      let isCurrentMonth = Bool.random()
      let isSelected = Bool.random()
      let highlightPart = highlightParts.randomElement()!

      let day1 = NNCalendarLogic.Day(date)
        .with(dateDescription: description)
        .with(currentMonth: isCurrentMonth)
        .with(selected: isSelected)
        .with(highlightPart: highlightPart)

      let day2 = NNCalendarLogic.Day(date)
        .with(dateDescription: description)
        .with(currentMonth: isCurrentMonth)
        .with(selected: isSelected)
        .with(highlightPart: highlightPart)

      XCTAssertEqual(day1.isToday, isToday)
      XCTAssertNotEqual(day1.isSelected, day1.toggleSelection().isSelected)
      XCTAssertEqual(day1, day2)
    }
  }

  public func test_weekdayImplementation_shouldWorkCorrectly() {
    /// Setup & When
    for _ in 0..<iterations! {
      for weekday in 1...7 {
        let wd1 = NNCalendarLogic.Weekday(weekday, String(describing: weekday))
        let wd2 = NNCalendarLogic.Weekday(weekday, String(describing: weekday))

        /// Then
        XCTAssertEqual(wd1, wd2)
      }
    }
  }

  public func test_monthImplementation_shouldWorkCorrectly() {
    /// Setup && Then
    for _ in 0..<iterations! {
      let month1 = NNCalendarLogic.Month(Date())
      let month2 = NNCalendarLogic.Month(Date())

      /// Then
      XCTAssertEqual(month1.hashValue, month2.hashValue)
    }
  }

  public func test_hightlightPosition_shouldWorkCorrectly() {
    XCTAssertTrue(NNCalendarLogic.HighlightPart.startAndEnd.contains(.start))
    XCTAssertTrue(NNCalendarLogic.HighlightPart.startAndEnd.contains(.end))
    XCTAssertFalse(NNCalendarLogic.HighlightPart.startAndEnd.contains(.mid))
  }
}
