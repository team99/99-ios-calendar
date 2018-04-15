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
  fileprivate var defaultViewModelDep: NNWeekdayDisplayViewModelDependency!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.WeekdayDisplay.Model()
    viewModel = NNCalendar.WeekdayDisplay.ViewModel(model)
    defaultViewModelDep = NNCalendar.WeekdayDisplay.ViewModel.DefaultDependency()
  }
}

public extension WeekdayDisplayTest {
  public func test_multipleConstructors_shouldWork() {
    let model1 = NNCalendar.WeekdayDisplay.Model(self)

    for weekday in 0..<7 {
      XCTAssertEqual(model1.weekdayDescription(weekday),
                     weekdayDescription(weekday))
    }

    let viewModel1 = NNCalendar.WeekdayDisplay.ViewModel(self, model1)
    XCTAssertEqual(viewModel1.weekdayCount, weekdayCount)
  }
}

public extension WeekdayDisplayTest {
  public func test_weekdayStream_shouldEmitCorrectWeekdays() {
    /// Setup
    let weekdayObserver = scheduler!.createObserver([NNCalendar.Weekday].self)
    viewModel!.weekdayStream.subscribe(weekdayObserver).disposed(by: disposable)
    viewModel!.setupWeekDisplayBindings()

    /// When & Then
    let weekdayCount = viewModel.weekdayCount
    let firstWeekday = defaultViewModelDep.firstWeekday
    let actualRange = (firstWeekday..<(firstWeekday + weekdayCount)).map({$0})

    let emittedWeekdays = weekdayObserver.nextElements()
      .flatMap({$0.map({$0.weekday})})

    XCTAssertEqual(emittedWeekdays, actualRange)
  }

  public func test_weekdaySelection_shouldWork() {
    /// Setup
    let selectionObserver = scheduler!.createObserver(Int.self)
    let weekdayIndexRange = (0..<viewModel!.weekdayCount).map({$0})

    viewModel!.weekdaySelectionStream
      .subscribe(selectionObserver)
      .disposed(by: disposable)

    viewModel!.setupWeekDisplayBindings()

    /// When
    weekdayIndexRange.forEach(viewModel!.weekdaySelectionIndexReceiver.onNext)

    /// Then
    XCTAssertEqual(weekdayIndexRange.map({$0 + 1}),
                   selectionObserver.nextElements())
  }
}

extension WeekdayDisplayTest: NNWeekdayDisplayModelDependency {
  public func weekdayDescription(_ weekday: Int) -> String {
    return "\(weekday)"
  }
}

extension WeekdayDisplayTest: NNWeekdayDisplayViewModelDependency {
  public var weekdayCount: Int {
    return 5
  }

  public var firstWeekday: Int {
    return 1
  }
}
