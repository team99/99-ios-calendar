//
//  MonthGridTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 14/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import RxTest
import SwiftUtilities
import SwiftUtilitiesTests
import XCTest
@testable import calendar99_logic

/// Tests for month grid.
public final class MonthGridTest: RootTest {
  fileprivate var model: NNCalendarLogic.MonthGrid.Model!
  fileprivate var viewModel: NNCalendarLogic.MonthGrid.ViewModel!

  override public func setUp() {
    super.setUp()
    model = NNCalendarLogic.MonthGrid.Model(self)
    viewModel = NNCalendarLogic.MonthGrid.ViewModel(model!)
  }
}

public extension MonthGridTest {
  public func test_gridSelectionReceiverAndStream_shouldWork() {
    /// Setup
    let selectionObs = scheduler!.createObserver(NNCalendarLogic.GridPosition.self)

    viewModel.gridSelectionStream
      .subscribe(selectionObs)
      .disposed(by: disposable!)

    /// When
    for _ in 0..<iterations! {
      let month = Int.random(0, 1000)
      let day = Int.random(0, 1000)
      let selection = NNCalendarLogic.GridPosition(month, day)
      viewModel.gridSelectionReceiver.onNext(selection)
      waitOnMainThread(waitDuration!)

      /// Then
      let lastSelection = selectionObs.nextElements().last!
      XCTAssertEqual(lastSelection, selection)
    }
  }
}

extension MonthGridTest: NNMonthGridModelDependency {
  public var weekdayStacks: Int {
    return NNCalendarLogic.Util.defaultWeekdayStacks
  }
}
