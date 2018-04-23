//
//  ReduxCalendarTest.swift
//  calendar99-reduxTests
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import HMReactiveRedux
import SwiftUtilities
import XCTest
@testable import calendar99_logic
@testable import calendar99_redux

public final class ReduxCalendarTest: RootTest {}

public extension ReduxCalendarTest {
  public func test_calendarActions_shouldWork() {
    /// Setup
    var state = TreeState<Any>.empty()
    var action: NNCalendarRedux.Calendar.Action!
    var path: String!

    /// When & Then
    let currentMonth = NNCalendar.Month(Date.random()!)
    path = NNCalendarRedux.Calendar.Action.currentMonthPath
    action = NNCalendarRedux.Calendar.Action.updateCurrentMonth(currentMonth)
    state = NNCalendarRedux.Calendar.Reducer.reduce(state, action)
    let storedMonth = state.stateValue(path).value! as! NNCalendar.Month
    XCTAssertEqual(storedMonth, currentMonth)

    path = NNCalendarRedux.Calendar.Action.selectionPath
    let selectionCount = 1000
    let firstWday = Int.random(1, 7)

    let selections = Set((0..<selectionCount)
      .map({(ix: Int) -> NNCalendar.Selection in
        switch ix % 2 {
        case 1:
          return NNCalendar.RepeatWeekdaySelection(Int.random(0, 7), firstWday)

        default:
          return NNCalendar.DateSelection(Date.random()!, firstWday)
        }
      }))

    action = NNCalendarRedux.Calendar.Action.updateSelection(selections)
    state = NNCalendarRedux.Calendar.Reducer.reduce(state, action)
    let storedSl = state.stateValue(path).value! as! Set<NNCalendar.Selection>
    XCTAssertEqual(storedSl, selections)

    action = NNCalendarRedux.Calendar.Action.clearAll
    state = NNCalendarRedux.Calendar.Reducer.reduce(state, action)
    XCTAssertTrue(state.isEmpty)
  }
}
