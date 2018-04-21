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
  fileprivate var initialMonth: NNCalendar.Month!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendar.Month>!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.MonthControl.Model(self)
    viewModel = NNCalendar.MonthControl.ViewModel(model!)
    initialMonth = NNCalendar.Month(Date())
    currentMonthSb = BehaviorSubject(value: initialMonth!)
  }
}

public extension MonthControlTest {
  public func test_navigateToPreviousOrNextMonth_shouldWork() {
    /// Setup
    viewModel!.setupMonthControlBindings()
    var prevMonth = initialMonth!

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      let jump = UInt(Int.random(1, 20))

      if forward {
        viewModel.currentMonthForwardReceiver.onNext(jump)
      } else {
        viewModel.currentMonthBackwardReceiver.onNext(jump)
      }

      waitOnMainThread(waitDuration!)

      /// Then
      let currentMonth = try! currentMonthSb.value()
      let monthOffset = prevMonth.monthOffset(from: currentMonth)
      prevMonth = currentMonth

      if forward {
        XCTAssertEqual(monthOffset, -Int(jump))
      } else {
        XCTAssertEqual(monthOffset, Int(jump))
      }
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
