//
//  SelectableWeekdayTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 15/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import SwiftUtilities
import XCTest
@testable import calendar99_logic

/// Tests for selectable weekday display.
public final class SelectableWeekdayTest: RootTest {
  fileprivate var model: NNCalendar.SelectWeekday.Model!
  fileprivate var viewModel: NNCalendar.SelectWeekday.ViewModel!
  fileprivate var allDateSelectionSb: BehaviorSubject<Try<Set<NNCalendar.Selection>>>!
  fileprivate var currentMonth: NNCalendar.Month!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendar.Month>!
  fileprivate var defaultModelDp: NNSelectableWeekdayModelDependency!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.SelectWeekday.Model(self)
    viewModel = NNCalendar.SelectWeekday.ViewModel(model!)
    allDateSelectionSb = BehaviorSubject(value: Try.failure(""))
    currentMonth = NNCalendar.Month(Date())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
    defaultModelDp = NNCalendar.SelectWeekday.Model.DefaultDependency(self)
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
    let viewModel1 = NNCalendar.SelectWeekday.ViewModel(weekdayVM, model1)
    let viewModel2 = NNCalendar.SelectWeekday.ViewModel(model2)
    XCTAssertEqual(viewModel1.weekdayCount, viewModel2.weekdayCount)
    XCTAssertEqual(defaultModelDp.firstWeekday, 1)

    let weekdays = try! viewModel!.weekdayStream.take(1).toBlocking().first()!
    let firstWeekday = defaultModelDp!.firstWeekday
    let weekdayCount = viewModel!.weekdayCount

    XCTAssertEqual((firstWeekday..<(firstWeekday + weekdayCount)).map({$0}),
                   weekdays.map({$0.weekday}))
  }

  public func test_selectWeekday_shouldWork() {
    /// Setup
    let calendar = Calendar.current
    viewModel!.setupWeekDisplayBindings()

    /// When && Then
    for i in 0..<iterations! {
      let currentMonth = self.currentMonth!.with(monthOffset: i)
      currentMonthSb.onNext(currentMonth!)
      waitOnMainThread(waitDuration!)

      for weekdayIndex in 0..<6 {
        viewModel!.weekdaySelectionIndexReceiver.onNext(weekdayIndex)
        var selections = try! allDateSelectionSb.value().getOrElse([])
        XCTAssertGreaterThanOrEqual(selections.count, 4)

        XCTAssertTrue(selections
          .flatMap({$0 as? NNCalendar.DateSelection})
          .map({calendar.component(.weekday, from: $0.date)})
          .all({$0 == weekdayIndex + 1}))

        viewModel!.weekdaySelectionIndexReceiver.onNext(weekdayIndex)
        selections = try! allDateSelectionSb.value().value!
        XCTAssertEqual(selections.count, 0)
      }
    }
  }
}

extension SelectableWeekdayTest: NNSelectableWeekdayNoDefaultModelDependency {
  public var allDateSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return allDateSelectionSb.mapObserver(Try.success)
  }

  public var allDateSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    return allDateSelectionSb.asObservable()
  }

  public var currentMonthStream: Observable<NNCalendar.Month> {
    return currentMonthSb.asObservable()
  }
}
