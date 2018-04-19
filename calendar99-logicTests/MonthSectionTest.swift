//
//  MonthSectionTest.swift
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

/// Tests for month section.
public final class MonthSectionTest: RootTest {
  fileprivate var model: NNCalendar.MonthSection.Model!
  fileprivate var viewModel: NNCalendar.MonthSection.ViewModel!
  fileprivate var currentMonth: NNCalendar.Month!
  fileprivate var allDateSelectionSb: BehaviorSubject<Try<Set<NNCalendar.Selection>>>!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendar.Month>!
  fileprivate var defaultModelDp: NNMonthSectionModelDependency!
  fileprivate var sequentialDateCalc: NNCalendar.DateCalc.Sequential!

  override public func setUp() {
    super.setUp()
    let weekdayAwareDp = NNCalendar.WeekdayAware.Model.DefaultDependency()
    defaultModelDp = NNCalendar.MonthSection.Model.DefaultDependency(self)

    sequentialDateCalc = NNCalendar.DateCalc.Sequential(
      defaultModelDp.rowCount,
      defaultModelDp.columnCount,
      weekdayAwareDp.firstWeekday)

    model = NNCalendar.MonthSection.Model(self)
    viewModel = NNCalendar.MonthSection.ViewModel(model!)
    currentMonth = NNCalendar.Month(Date())
    allDateSelectionSb = BehaviorSubject(value: Try.failure(""))
    currentMonthSb = BehaviorSubject(value: currentMonth!)
  }
}

public extension MonthSectionTest {
  public func test_defaultDependencies_shouldWork() {
    let monthControlModel = NNCalendar.MonthControl.Model(defaultModelDp!)
    let monthGridModel = NNCalendar.MonthGrid.Model(defaultModelDp!)
    let daySelectionModel = NNCalendar.DaySelection.Model(defaultModelDp!)

    let model1 = NNCalendar.MonthSection.Model(monthControlModel,
                                               monthGridModel,
                                               daySelectionModel,
                                               defaultModelDp)

    let model2 = NNCalendar.MonthSection.Model(defaultModelDp)
    let currentMonth = self.currentMonth!
    let pastMonths = pastMonthsFromCurrent
    let futureMonths = futureMonthsFromCurrent
    let months1 = model1.getAvailableMonths(currentMonth, pastMonths, futureMonths)
    let months2 = model2.getAvailableMonths(currentMonth, pastMonths, futureMonths)
    XCTAssertEqual(months1, months2)
    XCTAssertEqual(model1.firstWeekday, firstWeekday)
    XCTAssertEqual(model2.firstWeekday, firstWeekday)

    let monthControlVM = NNCalendar.MonthControl.ViewModel(monthControlModel)
    let monthGridVM = NNCalendar.MonthGrid.ViewModel(monthGridModel)
    let daySelectionVM = NNCalendar.DaySelection.ViewModel(daySelectionModel)

    let viewModel1 = NNCalendar.MonthSection.ViewModel(monthControlVM,
                                                       monthGridVM,
                                                       daySelectionVM,
                                                       model1)

    let viewModel2 = NNCalendar.MonthSection.ViewModel(model2)
    viewModel1.setupAllBindingsAndSubBindings()
    viewModel2.setupAllBindingsAndSubBindings()
    let comps1 = try! viewModel1.monthCompStream.take(1).toBlocking().first()!
    let comps2 = try! viewModel2.monthCompStream.take(1).toBlocking().first()!
    XCTAssertEqual(comps1, comps2)
  }

  public func test_monthComponentStream_shouldEmitCorrectMonths() {
    /// Setup
    viewModel!.setupMonthSectionBindings()

    /// When
    let monthComps = try! viewModel!.monthCompStream.take(1).toBlocking().first()!

    /// Then
    let pastOffset = pastMonthsFromCurrent
    let futureOffset = futureMonthsFromCurrent
    let firstMonth = currentMonth!.with(monthOffset: -pastOffset)!
    let lastMonth = currentMonth!.with(monthOffset: futureOffset)!
    XCTAssertEqual(monthComps.count, viewModel.totalMonthCount)
    XCTAssertEqual(monthComps.first!.month, firstMonth)
    XCTAssertEqual(monthComps.last!.month, lastMonth)
  }

  public func test_gridSelections_shouldWorkCorrectly() {
    /// Setup
    viewModel!.setupMonthSectionBindings()
    viewModel!.setupDaySelectionBindings()
    let pastOffset = pastMonthsFromCurrent
    let futureOffset = futureMonthsFromCurrent * 2
    let rowCount = viewModel!.rowCount
    let columnCount = viewModel!.columnCount
    let months = try! viewModel!.monthCompStream.take(1).toBlocking().first()!

    /// When
    for offset in 0..<(pastOffset + 1 + futureOffset) {
      // Select the month to test. The range is wider than it needs to be
      // because we want to test that month indexes which lie outside range are
      // filtered out.
      if offset < pastOffset {
        viewModel!.currentMonthBackwardReceiver.onNext(UInt(offset))
      } else {
        viewModel!.currentMonthForwardReceiver.onNext(UInt(offset))
      }

      waitOnMainThread(waitDuration!)

      let dayIndex = Int.random(0, rowCount * columnCount)
      let selection = NNCalendar.GridSelection(offset, dayIndex)
      let withinRange = offset < months.count

      let selectedDate = (withinRange
        ? viewModel.calculateDayFromFirstDate(months[offset].month, dayIndex)
        : nil)?.date

      let wasSelected = selectedDate.map({viewModel!.isDateSelected($0)}) ?? false
      viewModel!.gridSelectionReceiver.onNext(selection)
      waitOnMainThread(waitDuration!)

      /// Then
      if let selectedDate = selectedDate {
        XCTAssertNotEqual(isDateSelected(selectedDate), wasSelected)
      }
    }
  }

  public func test_gridSelectionChanges_shouldWorkCorrectly() {
    /// Setup
    let selectionChangesObs = scheduler!.createObserver(Set<NNCalendar.GridSelection>.self)
    let rowCount = viewModel!.rowCount
    let columnCount = viewModel!.columnCount
    let firstWeekday = model!.firstWeekday
    viewModel!.setupMonthSectionBindings()
    let monthComps = try! viewModel!.monthCompStream.take(1).toBlocking().first()!

    viewModel!.gridSelectionChangesStream
      .subscribe(selectionChangesObs)
      .disposed(by: disposable!)

    /// When
    for _ in 0..<iterations! {
      // Only select within the month range that could have previous and next
      // months, so that we are sure there will always be valid date selections.
      // For e.g., month index 0 & day index 0 will yield no selections because
      // the default grid selection calculator takes into account 3 consecutive
      // months, and day index 0 falls out of the current month range if the
      // first day is not at index 0, for e.g., if we specify Monday as the
      // first day of the week:
      // - The MonthComp for May 2018 has Monday as 30th April.
      // - The first day of May (i.e. 1st May) is a Tuesday.
      // - Therefore, if May 2018 is lies at index 0 of the month comp Array,
      // day index 0 would be in April 2018, but since April 2018 is not within
      // the month comp range, we end up with no selection.
      let monthIndex = Int.random(1, monthComps.count - 1)
      let dayIndex = Int.random(0, rowCount * columnCount)
      let gridSelection = NNCalendar.GridSelection(monthIndex, dayIndex)
      let month = monthComps[monthIndex].month
      let selectedDay = viewModel!.calculateDayFromFirstDate(month, dayIndex)!
      let wasSelected = viewModel!.isDateSelected(selectedDay.date)

      allDateSelectionReceiver.onNext(Set(arrayLiteral:
        NNCalendar.DateSelection(selectedDay.date, firstWeekday)))

      waitOnMainThread(waitDuration!)

      /// Then
      let lastChanges = selectionChangesObs.nextElements().last!

      // Since we only extract differences, if the calculated date has already
      // been selected it should be skipped.
      XCTAssertNotEqual(lastChanges.contains(gridSelection), wasSelected)
    }
  }

  public func test_monthSelectionIndex_shouldWorkCorrectly() {
    /// Setup
    let indexObs = scheduler.createObserver(Int.self)
    var currentMonth = self.currentMonth!

    viewModel!.currentMonthSelectionIndexStream
      .subscribe(indexObs)
      .disposed(by: disposable!)

    viewModel!.setupMonthControlBindings()
    viewModel!.setupMonthSectionBindings()
    let months = try! viewModel!.monthCompStream.take(1).toBlocking().first()!
    var prevIndex = pastMonthsFromCurrent

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      currentMonth = currentMonth.with(monthOffset: forward ? 1 : -1)!
      let index = months.index(where: {$0.month == currentMonth})

      if forward {
        viewModel!.currentMonthForwardReceiver.onNext(1)
      } else {
        viewModel!.currentMonthBackwardReceiver.onNext(1)
      }

      waitOnMainThread(waitDuration!)

      /// Then
      let lastIndex = indexObs.nextElements().last!
      XCTAssertEqual(lastIndex, index ?? prevIndex)
      prevIndex = lastIndex
    }
  }

  public func test_calculateHighlightParts_shouldWorkCorrectly() {
    /// Setup
    let calendar = Calendar.current
    let selectionCount = 100
    let firstWeekday = model!.firstWeekday

    /// When
    for _ in 0..<iterations! {
      let startDate = Date.random()!

      let selectedDates = (0..<selectionCount)
        .map({calendar.date(byAdding: .day, value: $0, to: startDate)!})

      let selections = selectedDates.map({NNCalendar.DateSelection($0, firstWeekday)})
      allDateSelectionReceiver.onNext(Set(selections))
      waitOnMainThread(waitDuration!)

      /// Then
      let highlight1 = selectedDates.map({viewModel!.calculateHighlightPart($0)})
      let highlight2 = selectedDates.map({calculateHighlightPart($0)})
      XCTAssertEqual(highlight1, highlight2)
    }
  }
}

extension MonthSectionTest: NNMonthSectionNoDefaultModelDependency {
  public var firstWeekday: Int {
    return defaultModelDp.firstWeekday
  }

  public var pastMonthsFromCurrent: Int {
    return 100
  }

  public var futureMonthsFromCurrent: Int {
    return 100
  }

  public func calculateHighlightPart(_ date: Date) -> NNCalendar.HighlightPart {
    return try! allDateSelectionSb.value()
      .map({NNCalendar.Util.calculateHighlightPart($0, date)})
      .getOrElse(.none)
  }

  public var allDateSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return allDateSelectionSb.mapObserver(Try.success)
  }

  public var allDateSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
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
    return try! allDateSelectionSb.value()
      .map({$0.contains(where: {$0.isDateSelected(date)})})
      .getOrElse(false)
  }
}
