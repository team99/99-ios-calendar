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

  override public func setUp() {
    super.setUp()
    model = NNCalendar.MonthDisplay.Model(self)
    viewModel = NNCalendar.MonthDisplay.ViewModel(model)
    currentMonth = NNCalendar.Month(Date())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
    allDateSelectionSb = BehaviorSubject(value: Set<Date>())
    defaultViewModelDp = NNCalendar.MonthDisplay.ViewModel.DefaultDependency()
  }
}

public extension MonthDisplayTest {
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

  public func test_gridSelectionIndexChanges_shouldWork() {
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
      if wasSelected {
        XCTAssertFalse(lastChanges.contains(selectedIndex))
      } else {
        XCTAssertTrue(lastChanges.contains(selectedIndex))
      }
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
