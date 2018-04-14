//
//  SelectableWeekdayTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 15/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import XCTest
@testable import calendar99_logic

/// Tests for selectable weekday display.
public final class SelectableWeekdayTest: RootTest {
  fileprivate var model: NNCalendar.SelectWeekday.Model!
  fileprivate var viewModel: NNCalendar.SelectWeekday.ViewModel!
  fileprivate var allDateSelectionSb: BehaviorSubject<Set<Date>>!
  fileprivate var currentComp: NNCalendar.MonthComp!
  fileprivate var currentCompSb: BehaviorSubject<NNCalendar.MonthComp>!
  fileprivate var defaultModelDp: NNSelectableWeekdayModelDependency!
  fileprivate var defaultViewModelDp: NNSelectableWeekdayViewModelDependency!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.SelectWeekday.Model(self)
    viewModel = NNCalendar.SelectWeekday.ViewModel(model!)
    allDateSelectionSb = BehaviorSubject(value: Set())
    currentComp = NNCalendar.MonthComp(Date())
    currentCompSb = BehaviorSubject(value: currentComp!)
    defaultModelDp = NNCalendar.SelectWeekday.Model.DefaultDependency(self)
    defaultViewModelDp = NNCalendar.SelectWeekday.ViewModel.DefaultDependency()
  }
}

public extension SelectableWeekdayTest {
  public func test_defaultDependencies_shouldWork() {
    let weekdayModel = NNCalendar.WeekdayDisplay.Model()
    let model1 = NNCalendar.SelectWeekday.Model(weekdayModel, defaultModelDp)
    let model2 = NNCalendar.SelectWeekday.Model(defaultModelDp)

    for weekday in 1...7 {
      XCTAssertEqual(model1.weekdayDescription(weekday),
                     model2.weekdayDescription(weekday))
    }

    let weekdayVM = NNCalendar.WeekdayDisplay.ViewModel(weekdayModel)
    let viewModel1 = NNCalendar.SelectWeekday.ViewModel(weekdayVM, defaultViewModelDp, model1)
    let viewModel2 = NNCalendar.SelectWeekday.ViewModel(defaultViewModelDp, model2)
    XCTAssertEqual(viewModel1.weekdayCount, viewModel2.weekdayCount)
    XCTAssertEqual(defaultViewModelDp.firstDayOfWeek, 1)

    let weekdays = try! viewModel!.weekdayStream.take(1).toBlocking().first()!
    let firstWeekday = defaultViewModelDp!.firstDayOfWeek
    let weekdayCount = viewModel!.weekdayCount

    XCTAssertEqual((firstWeekday..<(firstWeekday + weekdayCount)).map({$0}),
                   weekdays.map({$0.dayIndex}))
  }

  public func test_selectWeekday_shouldWork() {
    /// Setup
    let calendar = Calendar.current
    viewModel!.setupWeekDisplayBindings()

    /// When && Then
    for i in 0..<iterations! {
      let currentComp = self.currentComp!.with(monthOffset: i)
      currentCompSb.onNext(currentComp!)

      for weekdayIndex in 0..<6 {
        viewModel!.weekdaySelectionIndexReceiver.onNext(weekdayIndex)
        var selections = try! allDateSelectionSb.value()
        XCTAssertGreaterThanOrEqual(selections.count, 4)

        XCTAssertTrue(selections
          .map({calendar.component(.weekday, from: $0)})
          .all({$0 == weekdayIndex + 1}))

        viewModel!.weekdaySelectionIndexReceiver.onNext(weekdayIndex)
        selections = try! allDateSelectionSb.value()
        XCTAssertEqual(selections.count, 0)
      }
    }
  }
}

extension SelectableWeekdayTest: NNSelectableWeekdayNoDefaultModelDependency {
  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return allDateSelectionSb.asObserver()
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return allDateSelectionSb.asObservable()
  }

  public var currentMonthCompStream: Observable<NNCalendar.MonthComp> {
    return currentCompSb.asObservable()
  }
}
