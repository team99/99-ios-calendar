//
//  HighlightPartDateCalculatorTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 17/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
import calendar99_logic

public final class HighlightPartDateCalculatorTest: RootTest {
  fileprivate var dateCalc: NNCalendar.DateCalc.HighlightPart!
  fileprivate var rowCount: Int!
  fileprivate var columnCount: Int!

  fileprivate var gridSelections: Set<NNCalendar.GridSelection> {
    return Set((0..<10).flatMap({monthIndex in
      (0..<iterations!).map({NNCalendar.GridSelection(monthIndex, $0)})
    }))
  }

  override public func setUp() {
    super.setUp()
    rowCount = 6
    columnCount = 7
    dateCalc = NNCalendar.DateCalc.HighlightPart(self, rowCount!, columnCount!)
  }
}

public extension HighlightPartDateCalculatorTest {
  public func test_calculateGridSelectionChanges_shouldWork() {
    /// Setup
    let actualGridSelections = gridSelections
    let totalDayCount = rowCount! * columnCount!

    /// When
    let newGridSelections = dateCalc.calculateGridSelectionChanges([], [], [])

    /// Then
    XCTAssertTrue(newGridSelections.all({
      $0.dayIndex >= 0 && $0.dayIndex < totalDayCount
    }))

    for gridSelection in actualGridSelections {
      let prevSelection = gridSelection.decrementingDayIndex()
      let nextSelection = gridSelection.incrementingDayIndex()

      if gridSelection.dayIndex >= 0 && gridSelection.dayIndex < totalDayCount {
        XCTAssertTrue(newGridSelections.contains(gridSelection))
      }

      if prevSelection.dayIndex >= 0 && gridSelection.dayIndex < totalDayCount {
        XCTAssertTrue(newGridSelections.contains(prevSelection))
      }

      if nextSelection.dayIndex < totalDayCount {
        XCTAssertTrue(newGridSelections.contains(nextSelection))
      }
    }
  }
}

extension HighlightPartDateCalculatorTest: NNMultiMonthGridSelectionCalculator {
  public func calculateGridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                                            _ prev: Set<NNCalendar.Selection>,
                                            _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridSelection>
  {
    return gridSelections
  }
}
