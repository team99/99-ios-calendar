//
//  WeekdayDisplayTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 14/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import RxTest
import XCTest
@testable import calendar99_logic

/// Tests for weekday display.
public final class WeekdayDisplayTest: RootTest {
  fileprivate var model: NNCalendar.WeekdayDisplay.Model!
  fileprivate var viewModel: NNCalendar.WeekdayDisplay.ViewModel!
  fileprivate var defaultModelDp: NNWeekdayDisplayModelDependency!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.WeekdayDisplay.Model(self)
    viewModel = NNCalendar.WeekdayDisplay.ViewModel(model)
    defaultModelDp = NNCalendar.WeekdayDisplay.Model.DefaultDependency(self)
  }
}

public extension WeekdayDisplayTest {
  public func test_defaultDependencies_shouldWork() {
    let model1 = NNCalendar.WeekdayDisplay.Model(defaultModelDp)

    for weekday in 0..<7 {
      XCTAssertEqual(model1.weekdayDescription(weekday),
                     defaultModelDp.weekdayDescription(weekday))
    }
  }
}

public extension WeekdayDisplayTest {
  public func test_weekdayStream_shouldEmitCorrectWeekdays() {
    /// Setup
    let weekdayObserver = scheduler!.createObserver([NNCalendar.Weekday].self)
    viewModel!.weekdayStream.subscribe(weekdayObserver).disposed(by: disposable)
    viewModel!.setupWeekDisplayBindings()

    /// When & Then
    let weekdayCount = NNCalendar.Util.weekdayCount
    let firstWeekday = defaultModelDp!.firstWeekday
    let actualRange = NNCalendar.Util.weekdayRange(firstWeekday, weekdayCount)

    let emittedWeekdays = weekdayObserver.nextElements()
      .flatMap({$0.map({$0.weekday})})

    XCTAssertEqual(emittedWeekdays, actualRange)
  }

  public func test_weekdaySelection_shouldWork() {
    /// Setup
    let selectionObs = scheduler!.createObserver(Int.self)
    let indexRange = (0..<NNCalendar.Util.weekdayCount).map({$0})
    let firstWeekday = model!.firstWeekday
    let weekdayRange = indexRange.map({NNCalendar.Util.weekdayWithIndex($0, firstWeekday)})
    viewModel!.weekdaySelectionStream.subscribe(selectionObs).disposed(by: disposable)
    viewModel!.setupWeekDisplayBindings()

    /// When
    indexRange.forEach(viewModel!.weekdaySelectionIndexReceiver.onNext)

    /// Then
    XCTAssertEqual(weekdayRange, selectionObs.nextElements())
  }
}

extension WeekdayDisplayTest: NNWeekdayDisplayNoDefaultModelDependency {
  public var firstWeekday: Int {
    return firstWeekdayForTest!
  }
}

