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
  fileprivate var weekdayStacks: Int!

  fileprivate var gridPositions: Set<NNCalendar.GridPosition> {
    return Set((0..<10).flatMap({monthIndex in
      (0..<iterations!).map({NNCalendar.GridPosition(monthIndex, $0)})
    }))
  }

  override public func setUp() {
    super.setUp()
    weekdayStacks = 6
    dateCalc = NNCalendar.DateCalc.HighlightPart(self, self, weekdayStacks!)
  }
}

public extension HighlightPartDateCalculatorTest {
  public func test_calculateGridSelectionChanges_shouldWork(
    _ calculatedPos: Set<NNCalendar.GridPosition>,
    _ totalDayCount: Int)
  {
    /// Setup
    let actualGridPositions = gridPositions

    /// When & Then
    XCTAssertTrue(calculatedPos.all({$0.dayIndex >= 0 && $0.dayIndex < totalDayCount}))

    for gridSelection in actualGridPositions {
      let prevSelection = gridSelection.decrementingDayIndex()
      let nextSelection = gridSelection.incrementingDayIndex()

      if gridSelection.dayIndex >= 0 && gridSelection.dayIndex < totalDayCount {
        XCTAssertTrue(calculatedPos.contains(gridSelection))
      }

      if prevSelection.dayIndex >= 0 && gridSelection.dayIndex < totalDayCount {
        XCTAssertTrue(calculatedPos.contains(prevSelection))
      }

      if nextSelection.dayIndex < totalDayCount {
        XCTAssertTrue(calculatedPos.contains(nextSelection))
      }
    }
  }

  public func test_calculateMultiMonthGridSelectionChanges_shouldWork() {
    let totalDayCount = weekdayStacks! * NNCalendar.Util.weekdayCount
    let currentMonth = NNCalendar.Month(Date())
    let newGridPositions = dateCalc.gridSelectionChanges([], currentMonth, [], [])
    test_calculateGridSelectionChanges_shouldWork(newGridPositions, totalDayCount)
  }

  public func test_calculateSingleMonthGridSelectionChanges_shouldWork() {
    let totalDayCount = 1000
    let currentMonth = NNCalendar.Month(Date())
    let currentMonthComp = NNCalendar.MonthComp(currentMonth, totalDayCount, 1)
    let newGridPositions = dateCalc.gridSelectionChanges(currentMonthComp, [], [])
    test_calculateGridSelectionChanges_shouldWork(newGridPositions, totalDayCount)
  }
}

extension HighlightPartDateCalculatorTest: NNMultiMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                                   _ currentMonth: NNCalendar.Month,
                                   _ prev: Set<NNCalendar.Selection>,
                                   _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridPosition>
  {
    return gridPositions
  }
}

extension HighlightPartDateCalculatorTest: NNSingleMonthGridSelectionCalculator {
  public func gridSelectionChanges(_ monthComp: NNCalendar.MonthComp,
                                   _ prev: Set<NNCalendar.Selection>,
                                   _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridPosition>
  {
    return gridPositions
  }
}
