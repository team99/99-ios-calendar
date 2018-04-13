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
  fileprivate var initialComp: NNCalendar.MonthComp!
  fileprivate var currentMonthComp: BehaviorSubject<NNCalendar.MonthComp>!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.MonthControl.Model(self)
    viewModel = NNCalendar.MonthControl.ViewModel(model!)
    initialComp = NNCalendar.MonthComp(Date())
    currentMonthComp = BehaviorSubject(value: initialComp!)
  }

  public func test_navigateToPreviousOrNextMonth_shouldWork() {
    /// Setup
    viewModel.setupMonthControlBindings()
    var prevComp = initialComp!

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      let jump = UInt(Int.random(1, 20))

      if forward {
        viewModel.currentMonthForwardReceiver.onNext(jump)
      } else {
        viewModel.currentMonthBackwardReceiver.onNext(jump)
      }

      /// Then
      let currentComp = try! currentMonthComp.value()
      let monthOffset = prevComp.monthOffset(from: currentComp)
      prevComp = currentComp

      if forward {
        XCTAssertEqual(monthOffset, -Int(jump))
      } else {
        XCTAssertEqual(monthOffset, Int(jump))
      }
    }
  }
}

extension MonthControlTest: NNMonthControlModelDependency {
  public var currentMonthCompReceiver: AnyObserver<NNCalendar.MonthComp> {
    return currentMonthComp.asObserver()
  }

  public var currentMonthCompStream: Observable<NNCalendar.MonthComp> {
    return currentMonthComp.asObservable()
  }
}
