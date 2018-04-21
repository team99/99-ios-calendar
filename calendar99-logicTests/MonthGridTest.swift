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
  fileprivate var model: NNCalendar.MonthGrid.Model!
  fileprivate var viewModel: NNCalendar.MonthGrid.ViewModel!
  fileprivate var defaultModelDp: NNMonthGridModelDependency!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.MonthGrid.Model()
    viewModel = NNCalendar.MonthGrid.ViewModel(model!)
    defaultModelDp = NNCalendar.MonthGrid.Model.DefaultDependency()
  }
}

public extension MonthGridTest {
  public func test_defaultDependencies_shouldWork() {
    let model1 = NNCalendar.MonthGrid.Model(defaultModelDp!)
    XCTAssertEqual(model1.weekdayStacks, defaultModelDp.weekdayStacks)
  }

  public func test_gridSelectionReceiverAndStream_shouldWork() {
    /// Setup
    let selectionObs = scheduler!.createObserver(NNCalendar.GridPosition.self)

    viewModel.gridSelectionStream
      .subscribe(selectionObs)
      .disposed(by: disposable!)

    /// When
    for _ in 0..<iterations! {
      let month = Int.random(0, 1000)
      let day = Int.random(0, 1000)
      let selection = NNCalendar.GridPosition(month, day)
      viewModel.gridSelectionReceiver.onNext(selection)
      waitOnMainThread(waitDuration!)

      /// Then
      let lastSelection = selectionObs.nextElements().last!
      XCTAssertEqual(lastSelection, selection)
    }
  }
}
