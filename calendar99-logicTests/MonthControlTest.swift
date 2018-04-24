//
//  MonthControlTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftUtilities
import XCTest
@testable import calendar99_logic

public final class MonthControlTest: RootTest {
  fileprivate var model: NNCalendar.MonthControl.Model!
  fileprivate var viewModel: NNMonthControlViewModelType!
  fileprivate var currentMonth: NNCalendar.Month!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendar.Month>!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.MonthControl.Model(self)
    viewModel = NNCalendar.MonthControl.ViewModel(model!)
    currentMonth = NNCalendar.Month(Date())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
  }
}

public extension MonthControlTest {
  public func test_navigateToPreviousOrNextMonth_shouldWork() {
    /// Setup
    viewModel!.setupMonthControlBindings()
    var prevMonth = currentMonth!

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      let currentMonth = prevMonth.with(monthOffset: forward ? 1 : -1)!
      viewModel!.currentMonthReceiver.onNext(currentMonth)
      waitOnMainThread(waitDuration!)

      /// Then
      let monthOffset = prevMonth.monthOffset(from: currentMonth)
      prevMonth = currentMonth
      XCTAssertEqual(monthOffset, forward ? -1 : 1)
    }
  }
}

extension MonthControlTest: NNMonthControlModelDependency {
  public var initialMonthStream: Single<NNCalendar.Month> {
    return currentMonthSb.take(1).asSingle()
  }

  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return currentMonthSb.asObserver()
  }

  public var currentMonthStream: Observable<NNCalendar.Month> {
    return currentMonthSb.asObservable()
  }
}
