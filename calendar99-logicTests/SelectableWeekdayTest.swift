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
  fileprivate var model: NNCalendarLogic.SelectWeekday.Model!
  fileprivate var viewModel: NNCalendarLogic.SelectWeekday.ViewModel!
  fileprivate var allSelectionSb: BehaviorSubject<Try<Set<NNCalendarLogic.Selection>>>!
  fileprivate var currentMonth: NNCalendarLogic.Month!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendarLogic.Month>!
  fileprivate var defaultModelDp: NNSelectWeekdayModelDependency!

  override public func setUp() {
    super.setUp()
    model = NNCalendarLogic.SelectWeekday.Model(self)
    viewModel = NNCalendarLogic.SelectWeekday.ViewModel(model!)
    allSelectionSb = BehaviorSubject(value: Try.failure(""))
    currentMonth = NNCalendarLogic.Month(Date())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
    defaultModelDp = NNCalendarLogic.SelectWeekday.Model.DefaultDependency(self)
  }
}

public extension SelectableWeekdayTest {
  public func test_defaultDependencies_shouldWork() {
    let weekdayModel = NNCalendarLogic.WeekdayDisplay.Model(defaultModelDp)
    let model1 = NNCalendarLogic.SelectWeekday.Model(weekdayModel, defaultModelDp)
    let model2 = NNCalendarLogic.SelectWeekday.Model(defaultModelDp)

    for weekday in 1...7 {
      XCTAssertEqual(model1.weekdayDescription(weekday),
                     model2.weekdayDescription(weekday))
    }

    XCTAssertEqual(defaultModelDp.firstWeekday, firstWeekdayForTest!)

    let weekdays = try! viewModel!.weekdayStream.take(1).toBlocking().first()!
    let firstWeekday = defaultModelDp!.firstWeekday
    let weekdayCount = NNCalendarLogic.Util.weekdayCount
    let weekdayRange = NNCalendarLogic.Util.weekdayRange(firstWeekday, weekdayCount)
    XCTAssertEqual(weekdayRange, weekdays.map({$0.weekday}))

    let weekdayVM = NNCalendarLogic.WeekdayDisplay.ViewModel(weekdayModel)
    let viewModel1 = NNCalendarLogic.SelectWeekday.ViewModel(weekdayVM, model1)
    let weekdays1 = try! viewModel1.weekdayStream.take(1).toBlocking().first()
    XCTAssertEqual(weekdays1, weekdays)
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
        let weekday = NNCalendarLogic.Util.weekdayWithIndex(weekdayIndex, firstWeekday)
        var selections = try! allSelectionSb.value().getOrElse([])
        XCTAssertGreaterThanOrEqual(selections.count, 4)

        selections
          .flatMap({$0 as? NNCalendarLogic.DateSelection})
          .map({calendar.component(.weekday, from: $0.date)})
          .forEach({XCTAssertEqual($0, weekday)})

        viewModel!.weekdaySelectionIndexReceiver.onNext(weekdayIndex)
        selections = try! allSelectionSb.value().value!
        XCTAssertEqual(selections.count, 0)
      }
    }
  }
}

extension SelectableWeekdayTest: NNSelectWeekdayNoDefaultModelDependency {
  public var firstWeekday: Int {
    return firstWeekdayForTest!
  }
  
  public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    return allSelectionSb.mapObserver(Try.success)
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
    return allSelectionSb.asObservable()
  }

  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return currentMonthSb.asObservable()
  }
}
