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
  fileprivate var defaultViewModelDp: NNMonthGridViewModelDependency!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.MonthGrid.Model(self)
    viewModel = NNCalendar.MonthGrid.ViewModel(self, model!)
    defaultViewModelDp = NNCalendar.MonthGrid.ViewModel.DefaultDependency()
  }
}

public extension MonthGridTest {
  public func test_defaultDependencies_shouldWork() {
    let vmWithDefault = NNCalendar.MonthGrid.ViewModel(model!)
    XCTAssertEqual(vmWithDefault.columnCount, 7)
    XCTAssertEqual(vmWithDefault.rowCount, 6)
    XCTAssertEqual(viewModel.columnCount, 7)
    XCTAssertEqual(viewModel.rowCount, 6)
    XCTAssertEqual(firstWeekday, 1)
  }

  public func test_gridSelectionReceiverAndStream_shouldWork() {
    /// Setup
    let selectionObs = scheduler!.createObserver(NNCalendar.GridSelection.self)

    viewModel.gridSelectionStream
      .subscribe(selectionObs)
      .disposed(by: disposable!)

    /// When
    for _ in 0..<iterations! {
      let month = Int.random(0, 1000)
      let day = Int.random(0, 1000)
      let selection = NNCalendar.GridSelection(month, day)
      viewModel.gridSelectionReceiver.onNext(selection)
      waitOnMainThread(waitDuration!)

      /// Then
      let lastSelection = selectionObs.nextElements().last!
      XCTAssertEqual(lastSelection, selection)
    }
  }
}

extension MonthGridTest: NNMonthGridModelDependency {}

extension MonthGridTest: NNMonthGridViewModelDependency {
  public var columnCount: Int {
    return defaultViewModelDp!.columnCount
  }

  public var rowCount: Int {
    return defaultViewModelDp!.rowCount
  }

  public var firstWeekday: Int {
    return defaultViewModelDp!.firstWeekday
  }
}