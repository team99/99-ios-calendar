//
//  MonthControlCommonTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 21/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxTest
import SwiftUtilities
import XCTest
@testable import calendar99_logic

/// Common tests for month control.
public protocol MonthControlCommonTestProtocol: CommonTestProtocol {}

public extension MonthControlCommonTestProtocol {
  public func test_backwardAndForwardReceiver_shouldWork(
    _ viewModel: NNMonthControlViewModelType,
    _ model: NNMonthAwareModelFunction)
  {
    /// Setup
    let monthObs = scheduler!.createObserver(NNCalendarLogic.Month.self)
    model.currentMonthStream.subscribe(monthObs).disposed(by: disposable!)
    viewModel.setupMonthControlBindings()
    var currentMonth = NNCalendarLogic.Month(Date())

    /// When
    for _ in 0..<iterations {
      let forward = Bool.random()
      currentMonth = currentMonth.with(monthOffset: forward ? 1 : -1)!

      if forward {
        viewModel.currentMonthForwardReceiver.onNext()
      } else {
        viewModel.currentMonthBackwardReceiver.onNext()
      }

      waitOnMainThread(waitDuration!)

      /// Then
      let lastMonth = monthObs.nextElements().last!
      XCTAssertEqual(lastMonth, currentMonth)
    }
  }

  public func test_minAndMaxMonths_shouldLimitMonthSelection(
    _ viewModel: NNMonthControlViewModelType,
    _ model: NNMonthControlModelFunction)
  {
    /// Setup
    let monthObs = scheduler!.createObserver(NNCalendarLogic.Month.self)
    model.currentMonthStream.subscribe(monthObs).disposed(by: disposable!)
    viewModel.setupMonthControlBindings()

    /// When & Then
    viewModel.currentMonthReceiver.onNext(model.minimumMonth)
    waitOnMainThread(waitDuration!)
    viewModel.currentMonthBackwardReceiver.onNext()
    waitOnMainThread(waitDuration!)
    XCTAssertEqual(monthObs.nextElements().last!, model.minimumMonth)

    viewModel.currentMonthReceiver.onNext(model.maximumMonth)
    waitOnMainThread(waitDuration!)
    viewModel.currentMonthForwardReceiver.onNext()
    waitOnMainThread(waitDuration!)
    XCTAssertEqual(monthObs.nextElements().last!, model.maximumMonth)
  }
}
