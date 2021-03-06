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
  fileprivate var model: NNCalendarLogic.WeekdayDisplay.Model!
  fileprivate var viewModel: NNCalendarLogic.WeekdayDisplay.ViewModel!

  override public func setUp() {
    super.setUp()
    model = NNCalendarLogic.WeekdayDisplay.Model(self)
    viewModel = NNCalendarLogic.WeekdayDisplay.ViewModel(model)
  }
}

public extension WeekdayDisplayTest {
  public func test_weekdayStream_shouldEmitCorrectWeekdays() {
    /// Setup
    let weekdayObserver = scheduler!.createObserver([NNCalendarLogic.Weekday].self)
    viewModel!.weekdayStream.subscribe(weekdayObserver).disposed(by: disposable)
    viewModel!.setupWeekDisplayBindings()

    /// When & Then
    let weekdayCount = NNCalendarLogic.Util.weekdayCount
    let firstWeekday = model!.firstWeekday
    let actualRange = NNCalendarLogic.Util.weekdayRange(firstWeekday, weekdayCount)

    let emittedWeekdays = weekdayObserver.nextElements()
      .flatMap({$0.map({$0.weekday})})

    XCTAssertEqual(emittedWeekdays, actualRange)
  }

  public func test_weekdaySelection_shouldWork() {
    /// Setup
    let selectionObs = scheduler!.createObserver(Int.self)
    let indexRange = (0..<NNCalendarLogic.Util.weekdayCount).map({$0})
    let firstWeekday = model!.firstWeekday
    let weekdayRange = indexRange.map({NNCalendarLogic.Util.weekdayWithIndex($0, firstWeekday)})
    viewModel!.weekdaySelectionStream.subscribe(selectionObs).disposed(by: disposable)
    viewModel!.setupWeekDisplayBindings()

    /// When
    indexRange.forEach(viewModel!.weekdaySelectionIndexReceiver.onNext)

    /// Then
    XCTAssertEqual(weekdayRange, selectionObs.nextElements())
  }
}

extension WeekdayDisplayTest: NNWeekdayDisplayModelDependency {
  public var firstWeekday: Int { return firstWeekdayForTest! }

  public func weekdayDescription(_ weekday: Int) -> String {
    return NNCalendarLogic.Util.defaultWeekdayDescription(weekday)
  }
}

