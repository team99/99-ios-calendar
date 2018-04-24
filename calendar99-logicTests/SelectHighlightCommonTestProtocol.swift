//
//  SelectHighlightCommonTestProtocol.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftUtilities
import XCTest
@testable import calendar99_logic

/// Common select highlight tests.
public protocol SelectHighlightCommonTestProtocol: CommonTestProtocol,
  NNSelectHighlightNoDefaultFunction {}

public extension SelectHighlightCommonTestProtocol {
  public func test_calculateHighlightParts_shouldWorkCorrectly(
    _ viewModel: NNSelectHighlightNoDefaultFunction,
    _ model: NNWeekdayAwareModelType & NNMultiDaySelectionNoDefaultFunction)
  {
    /// Setup
    let calendar = Calendar.current
    let selectionCount = 100
    let firstWeekday = model.firstWeekday

    /// When
    for _ in 0..<iterations! {
      let startDate = Date.random()!

      let selectedDates = (0..<selectionCount)
        .map({calendar.date(byAdding: .day, value: $0, to: startDate)!})

      let selections = selectedDates.map({NNCalendar.DateSelection($0, firstWeekday)})
      model.allSelectionReceiver.onNext(Set(selections))
      waitOnMainThread(waitDuration!)

      /// Then
      let highlight1 = selectedDates.map({viewModel.highlightPart($0)})
      let highlight2 = selectedDates.map({highlightPart($0)})
      XCTAssertEqual(highlight1, highlight2)
    }
  }
}
