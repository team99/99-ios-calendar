//
//  MonthDisplayTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftUtilities
import XCTest
@testable import calendar99_logic

public final class MonthDisplayTest: RootTest {
  fileprivate var model: NNCalendar.MonthDisplay.Model!
  fileprivate var viewModel: NNCalendar.MonthDisplay.ViewModel!
  fileprivate var currentMonth: NNCalendar.Month!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendar.Month>!
  fileprivate var allDateSelectionSb: BehaviorSubject<Set<Date>>!
  fileprivate var defaultViewModelDp: NNMonthDisplayViewModelDependency!
  fileprivate var defaultModelDp: NNMonthDisplayModelDependency!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.MonthDisplay.Model(self)
    viewModel = NNCalendar.MonthDisplay.ViewModel(model)
    currentMonth = NNCalendar.Month(Date())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
    allDateSelectionSb = BehaviorSubject(value: Set<Date>())
    defaultViewModelDp = NNCalendar.MonthDisplay.ViewModel.DefaultDependency()
    defaultModelDp = NNCalendar.MonthDisplay.Model.DefaultDependency(self)
  }
}

public extension MonthDisplayTest {
  public func test_defaultDependencies_shouldWork() {
    let monthControlModel = NNCalendar.MonthControl.Model(self)
    let monthGridModel = NNCalendar.MonthGrid.Model(self)
    let daySelectionModel = NNCalendar.DaySelection.Model(self)

    let model1 = NNCalendar.MonthDisplay.Model(monthControlModel,
                                               monthGridModel,
                                               daySelectionModel,
                                               defaultModelDp!)

    let model2 = NNCalendar.MonthDisplay.Model(defaultModelDp!)
    let initialMonth1 = try! model1.initialMonthStream.toBlocking().first()!
    let initialMonth2 = try! model2.initialMonthStream.toBlocking().first()!
    XCTAssertEqual(initialMonth1, initialMonth2)

    let monthControlVM = NNCalendar.MonthControl.ViewModel(monthControlModel)
    let monthGridVM = NNCalendar.MonthGrid.ViewModel(monthGridModel)
    let daySelectionVM = NNCalendar.DaySelection.ViewModel(daySelectionModel)

    let viewModel1 = NNCalendar.MonthDisplay.ViewModel(monthControlVM,
                                                       monthGridVM,
                                                       daySelectionVM,
                                                       defaultViewModelDp!,
                                                       model1)

    let viewModel2 = NNCalendar.MonthDisplay.ViewModel(defaultViewModelDp!, model2)
    viewModel1.setupAllBindingsAndSubBindings()
    viewModel2.setupAllBindingsAndSubBindings()
    XCTAssertEqual(viewModel1.rowCount, viewModel2.rowCount)
    XCTAssertEqual(viewModel1.columnCount, viewModel2.columnCount)

    XCTAssertEqual(
      try! viewModel1.dayStream.take(1).toBlocking().first(),
      try! viewModel2.dayStream.take(1).toBlocking().first()
    )
  }

  public func test_dayStreamForCurrentMonth_shouldWorkCorrectly() {
    /// Setup
    let dayObs = scheduler!.createObserver([NNCalendar.Day].self)
    var currentMonth = self.currentMonth!
    viewModel!.dayStream.subscribe(dayObs).disposed(by: disposable!)
    viewModel!.setupMonthDisplayBindings()
    viewModel!.setupMonthControlBindings()

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      let jump = Int.random(1, 20)
      currentMonth = currentMonth.with(monthOffset: forward ? jump : -jump)!

      let currentDays = model!.calculateDayRange(
        currentMonth,
        defaultViewModelDp!.firstWeekday,
        viewModel!.rowCount,
        viewModel!.columnCount)

      if forward {
        viewModel!.currentMonthForwardReceiver.onNext(UInt(jump))
      } else {
        viewModel!.currentMonthBackwardReceiver.onNext(UInt(jump))
      }

      waitOnMainThread(waitDuration!)

      /// Then
      let lastDays = dayObs.nextElements().last!
      XCTAssertEqual(lastDays, currentDays)
    }
  }

  public func test_gridSelectionStream_shouldWorkCorrectly() {
    /// Setup
    var currentMonth = self.currentMonth!
    let firstWeekday = defaultViewModelDp!.firstWeekday
    let rowCount = viewModel!.rowCount
    let columnCount = viewModel!.columnCount
    viewModel!.setupMonthDisplayBindings()
    viewModel!.setupMonthControlBindings()
    viewModel!.setupDaySelectionBindings()

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      currentMonth = currentMonth.with(monthOffset: forward ? 1 : -1)!

      let currentDays = model!.calculateDayRange(currentMonth,
                                                 firstWeekday,
                                                 rowCount,
                                                 columnCount)

      if forward {
        viewModel!.currentMonthForwardReceiver.onNext(1)
      } else {
        viewModel!.currentMonthBackwardReceiver.onNext(1)
      }

      waitOnMainThread(waitDuration!)

      // This will be ignored anyway, but we add in just to check.
      let monthIndex = Int.random(0, 1000)
      let dayIndex = Int.random(0, 1000)
      let gridSelection = NNCalendar.GridSelection(monthIndex, dayIndex)
      let validSelection = dayIndex < currentDays.count
      let selectedDay = validSelection ? currentDays[dayIndex] : nil
      let wasSelected = selectedDay.map({viewModel!.isDateSelected($0.date)}) ?? false
      viewModel!.gridSelectionReceiver.onNext(gridSelection)
      waitOnMainThread(waitDuration!)

      /// Then
      let lastSelections = try! allDateSelectionSb.value()

      // If the date was selected previously, it should be removed from all date
      // selections (thanks to single day selection logic).
      if let selectedDay = selectedDay {
        XCTAssertNotEqual(lastSelections.contains(selectedDay.date), wasSelected)
      }
    }
  }

  public func test_gridSelectionIndexChanges_shouldWorkCorrectly() {
    /// Setup
    let indexChangesObs = scheduler!.createObserver(Set<Int>.self)
    let rowCount = viewModel!.rowCount
    let columnCount = viewModel!.columnCount
    let firstWeekday = defaultViewModelDp.firstWeekday
    var currentMonth = self.currentMonth!

    viewModel!.gridDayIndexSelectionChangesStream
      .subscribe(indexChangesObs)
      .disposed(by: disposable!)

    viewModel!.setupMonthControlBindings()

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      currentMonth = currentMonth.with(monthOffset: forward ? 1 : -1)!

      if forward {
        viewModel!.currentMonthForwardReceiver.onNext(1)
      } else {
        viewModel!.currentMonthBackwardReceiver.onNext(1)
      }

      waitOnMainThread(waitDuration!)

      let dayRange = model!.calculateDayRange(currentMonth,
                                              firstWeekday,
                                              rowCount,
                                              columnCount)

      let selectedIndex = Int.random(0, rowCount * columnCount)
      let selectedDay = dayRange[selectedIndex]
      let wasSelected = viewModel!.isDateSelected(selectedDay.date)
      allDateSelectionSb.onNext(Set(arrayLiteral: selectedDay.date))
      waitOnMainThread(waitDuration!)

      /// Then
      let lastChanges = indexChangesObs.nextElements().last!

      // If this index is already selected previously, it should not appear in
      // in the set of index changes.
      XCTAssertNotEqual(lastChanges.contains(selectedIndex), wasSelected)
    }
  }
}

extension MonthDisplayTest: NNMonthDisplayNoDefaultModelDependency {
  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return allDateSelectionSb.asObserver()
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return allDateSelectionSb.asObservable()
  }

  public var initialMonthStream: Single<NNCalendar.Month> {
    return Single.just(currentMonth!)
  }

  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return currentMonthSb.asObserver()
  }

  public var currentMonthStream: Observable<NNCalendar.Month> {
    return currentMonthSb.asObservable()
  }

  public func isDateSelected(_ date: Date) -> Bool {
    return (try? allDateSelectionSb.value())?.contains(date) ?? false
  }
}
