//
//  MonthDisplayTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import SwiftUtilities
import XCTest
@testable import calendar99_logic

public final class MonthDisplayTest: RootTest {
  fileprivate var model: NNCalendarLogic.MonthDisplay.Model!
  fileprivate var viewModel: NNCalendarLogic.MonthDisplay.ViewModel!
  fileprivate var currentMonth: NNCalendarLogic.Month!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendarLogic.Month>!
  fileprivate var allSelectionSb: BehaviorSubject<Try<Set<NNCalendarLogic.Selection>>>!
  fileprivate var defaultModelDp: NNMonthDisplayModelDependency!

  override public func setUp() {
    super.setUp()
    model = NNCalendarLogic.MonthDisplay.Model(self)
    viewModel = NNCalendarLogic.MonthDisplay.ViewModel(model)
    currentMonth = NNCalendarLogic.Month(Date())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
    allSelectionSb = BehaviorSubject(value: Try.failure(""))
    defaultModelDp = NNCalendarLogic.MonthDisplay.Model.DefaultDependency(self)
  }
}

extension MonthDisplayTest: MonthControlCommonTestProtocol {
  public func test_backwardAndForwardReceiver_shouldWork() {
    test_backwardAndForwardReceiver_shouldWork(viewModel!, model!)
  }

  public func test_minAndMaxMonths_shouldLimitMonthSelection() {
    test_minAndMaxMonths_shouldLimitMonthSelection(viewModel!, model!)
  }
}

extension MonthDisplayTest: SelectHighlightCommonTestProtocol {
  public func test_calculateHighlightParts_shouldWorkCorrectly() {
    test_calculateHighlightParts_shouldWorkCorrectly(viewModel!, model!)
  }
}

public extension MonthDisplayTest {
  public func test_defaultDependencies_shouldWork() {
    let monthControlModel = NNCalendarLogic.MonthControl.Model(defaultModelDp)
    let monthGridModel = NNCalendarLogic.MonthGrid.Model(defaultModelDp)
    let daySelectionModel = NNCalendarLogic.DaySelect.Model(defaultModelDp)

    let model1 = NNCalendarLogic.MonthDisplay.Model(monthControlModel,
                                               monthGridModel,
                                               daySelectionModel,
                                               defaultModelDp!)

    let model2 = NNCalendarLogic.MonthDisplay.Model(defaultModelDp!)
    let initialMonth1 = try! model1.initialMonthStream.toBlocking().first()!
    let initialMonth2 = try! model2.initialMonthStream.toBlocking().first()!
    XCTAssertEqual(initialMonth1, initialMonth2)

    let monthControlVM = NNCalendarLogic.MonthControl.ViewModel(monthControlModel)
    let monthGridVM = NNCalendarLogic.MonthGrid.ViewModel(monthGridModel)
    let daySelectionVM = NNCalendarLogic.DaySelect.ViewModel(daySelectionModel)

    let viewModel1 = NNCalendarLogic.MonthDisplay.ViewModel(monthControlVM,
                                                       monthGridVM,
                                                       daySelectionVM,
                                                       model1)

    let viewModel2 = NNCalendarLogic.MonthDisplay.ViewModel(model2)
    viewModel1.setupAllBindingsAndSubBindings()
    viewModel2.setupAllBindingsAndSubBindings()
    XCTAssertEqual(viewModel1.weekdayStacks, viewModel2.weekdayStacks)

    XCTAssertEqual(
      try! viewModel1.dayStream.take(1).toBlocking().first(),
      try! viewModel2.dayStream.take(1).toBlocking().first()
    )
  }

  public func test_dayStreamForCurrentMonth_shouldWorkCorrectly() {
    /// Setup
    let dayObs = scheduler!.createObserver([NNCalendarLogic.Day].self)
    var currentMonth = self.currentMonth!
    viewModel!.dayStream.subscribe(dayObs).disposed(by: disposable!)
    viewModel!.setupMonthDisplayBindings()
    viewModel!.setupMonthControlBindings()

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      let jump = Int.random(1, 20)
      currentMonth = currentMonth.with(monthOffset: forward ? jump : -jump)!
      let currentDays = model!.dayRange(currentMonth)
      viewModel!.currentMonthReceiver.onNext(currentMonth)
      waitOnMainThread(waitDuration!)

      /// Then
      let lastDays = dayObs.nextElements().last!
      XCTAssertEqual(lastDays, currentDays)
    }
  }

  public func test_gridSelectionStream_shouldWorkCorrectly() {
    /// Setup
    var currentMonth = self.currentMonth!
    viewModel!.setupMonthDisplayBindings()
    viewModel!.setupMonthControlBindings()
    viewModel!.setupDaySelectionBindings()

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      currentMonth = currentMonth.with(monthOffset: forward ? 1 : -1)!
      let currentDays = model!.dayRange(currentMonth)
      viewModel!.currentMonthReceiver.onNext(currentMonth)
      waitOnMainThread(waitDuration!)

      // This will be ignored anyway, but we add in just to check.
      let monthIndex = Int.random(0, 1000)
      let dayIndex = Int.random(0, 1000)
      let gridPosition = NNCalendarLogic.GridPosition(monthIndex, dayIndex)
      let validSelection = dayIndex < currentDays.count
      let selectedDay = validSelection ? currentDays[dayIndex] : nil
      let wasSelected = selectedDay.map({viewModel!.isDateSelected($0.date)}) ?? false
      viewModel!.gridSelectionReceiver.onNext(gridPosition)
      waitOnMainThread(waitDuration!)

      /// Then
      let lastSelections = try! allSelectionSb.value().getOrElse([])

      // If the date was selected previously, it should be removed from all date
      // selections (thanks to single day selection logic).
      if let selectedDay = selectedDay {
        XCTAssertNotEqual(
          lastSelections.contains(where: {$0.contains(selectedDay.date)}),
          wasSelected)
      }
    }
  }

  public func test_gridSelectionIndexChanges_shouldWorkCorrectly() {
    /// Setup
    let indexChangesObs = scheduler!.createObserver(Set<Int>.self)
    let weekdayStacks = viewModel!.weekdayStacks
    let firstWeekday = model!.firstWeekday
    var currentMonth = self.currentMonth!

    viewModel!.gridDayIndexSelectionChangesStream
      .subscribe(indexChangesObs)
      .disposed(by: disposable!)

    viewModel!.setupMonthControlBindings()

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      currentMonth = currentMonth.with(monthOffset: forward ? 1 : -1)!
      viewModel!.currentMonthReceiver.onNext(currentMonth)
      waitOnMainThread(waitDuration!)

      let dayRange = model!.dayRange(currentMonth)
      let selectedIndex = Int.random(0, weekdayStacks * NNCalendarLogic.Util.weekdayCount)
      let selectedDay = dayRange[selectedIndex]
      let wasSelected = viewModel!.isDateSelected(selectedDay.date)

      allSelectionReceiver.onNext(Set(arrayLiteral:
        NNCalendarLogic.DateSelection(selectedDay.date, firstWeekday)))

      waitOnMainThread(waitDuration!)

      /// Then
      let lastChanges = indexChangesObs.nextElements().last!

      // If this index is already selected previously, it should not appear in
      // in the set of index changes.
      //
      // If we look at a similar test for MonthSectionView (for grid selection
      // changes), we will see that an extra step (navigating to the current
      // month) is added. Said step is not needed here because for this view,
      // there will always be only 1 month active at a time, so the month index
      // (which is used for calculation by the DateSelection object) is fixed.
      XCTAssertEqual(lastChanges.contains(selectedIndex), !wasSelected)
    }
  }
}

extension MonthDisplayTest: NNMonthDisplayNoDefaultModelDependency {
  public var firstWeekday: Int {
    return firstWeekdayForTest!
  }
  
  public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    return allSelectionSb.mapObserver(Try.success)
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
    return allSelectionSb.asObservable()
  }

  public var initialMonthStream: Single<NNCalendarLogic.Month> {
    return Single.just(currentMonth!)
  }

  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return currentMonthSb.asObserver()
  }

  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return currentMonthSb.asObservable()
  }

  public func isDateSelected(_ date: Date) -> Bool {
    return try! allSelectionSb.value()
      .map({$0.contains(where: {$0.contains(date)})})
      .getOrElse(false)
  }

  public func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart {
    return try! allSelectionSb.value()
      .map({NNCalendarLogic.Util.highlightPart($0, date)})
      .getOrElse(.none)
  }
}
