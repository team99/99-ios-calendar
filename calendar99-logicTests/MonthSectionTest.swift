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
  fileprivate var allSelectionSb: BehaviorSubject<Try<Set<NNCalendar.Selection>>>!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendar.Month>!
  fileprivate var defaultModelDp: NNMonthSectionModelDependency!

  override public func setUp() {
    super.setUp()
    defaultModelDp = NNCalendar.MonthSection.Model.DefaultDependency(self)
    model = NNCalendar.MonthSection.Model(self)
    viewModel = NNCalendar.MonthSection.ViewModel(model!)
    currentMonth = NNCalendar.Month(Date())
    allSelectionSb = BehaviorSubject(value: Try.failure(""))
    currentMonthSb = BehaviorSubject(value: currentMonth!)
  }
}

extension MonthSectionTest: MonthControlCommonTestProtocol {
  public func test_backwardAndForwardReceiver_shouldWork() {
    test_backwardAndForwardReceiver_shouldWork(viewModel!, model!)
  }

  public func test_minAndMaxMonths_shouldLimitMonthSelection() {
    test_minAndMaxMonths_shouldLimitMonthSelection(viewModel!, model!)
  }
}

extension MonthSectionTest: SelectHighlightCommonTestProtocol {
  public func test_calculateHighlightParts_shouldWorkCorrectly() {
    test_calculateHighlightParts_shouldWorkCorrectly(viewModel!, model!)
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
    XCTAssertEqual(monthComps.count, viewModel.totalMonthCount)
    XCTAssertEqual(monthComps.first!.month, minimumMonth)
    XCTAssertEqual(monthComps.last!.month, maximumMonth)
  }

  public func test_gridSelections_shouldWorkCorrectly() {
    /// Setup
    viewModel!.setupMonthSectionBindings()
    viewModel!.setupDaySelectionBindings()
    let weekdayStacks = viewModel!.weekdayStacks
    let minMonth = minimumMonth
    let maxMonth = maximumMonth
    let monthRange = NNCalendar.Util.monthRange(minMonth, maxMonth)
    let monthComps = try! viewModel!.monthCompStream.take(1).toBlocking().first()!

    /// When
    for (ix, currentMonth) in monthRange.enumerated() {
      viewModel!.currentMonthReceiver.onNext(currentMonth)
      waitOnMainThread(waitDuration!)

      let dayIndex = Int.random(0, weekdayStacks * NNCalendar.Util.weekdayCount)
      let selection = NNCalendar.GridPosition(ix, dayIndex)
      let withinRange = ix < monthComps.count

      let selectedDate = (withinRange
        ? viewModel.dayFromFirstDate(monthComps[ix].month, dayIndex)
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
    let selectionChangesObs = scheduler!.createObserver(Set<NNCalendar.GridPosition>.self)
    let weekdayStacks = viewModel!.weekdayStacks
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
      // the default grid position calculator takes into account 3 consecutive
      // months, and day index 0 falls out of the current month range if the
      // first day is not at index 0, for e.g., if we specify Monday as the
      // first day of the week:
      // - The MonthComp for May 2018 has Monday as 30th April.
      // - The first day of May (i.e. 1st May) is a Tuesday.
      // - Therefore, if May 2018 is lies at index 0 of the month comp Array,
      // day index 0 would be in April 2018, but since April 2018 is not within
      // the month comp range, we end up with no selection.
      let monthIndex = Int.random(1, monthComps.count - 1)
      let dayIndex = Int.random(0, weekdayStacks * NNCalendar.Util.weekdayCount)
      let gridPosition = NNCalendar.GridPosition(monthIndex, dayIndex)
      let monthComp = monthComps[monthIndex]
      let currentMonth = monthComp.month
      let selectedDay = viewModel!.dayFromFirstDate(currentMonth, dayIndex)!
      let selectionObj = NNCalendar.DateSelection(selectedDay.date, firstWeekday)
      let wasSelected = viewModel!.isDateSelected(selectedDay.date)
      let containedInCurrentMonth = monthComp.contains(selectedDay.date)

      // We must go to the current month because the grid selection changes are
      // only calculate for said month. For more information, consult the docs
      // for DateSelection.
      viewModel!.currentMonthReceiver.onNext(currentMonth)
      waitOnMainThread(waitDuration!)

      allSelectionReceiver.onNext(Set(arrayLiteral: selectionObj))
      waitOnMainThread(waitDuration!)

      /// Then
      let lastChanges = selectionChangesObs.nextElements().last!

      // Since we only extract differences, if the calculated date has already
      // been selected it should be skipped. Also, since DateSelection only
      // calculates grid selection changes for the current month, checking
      // wasSelected alone is not enough.
      XCTAssertEqual(lastChanges.contains(gridPosition),
                     !wasSelected && containedInCurrentMonth)
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
    var prevIndex = 0

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      currentMonth = currentMonth.with(monthOffset: forward ? 1 : -1)!
      let index = months.index(where: {$0.month == currentMonth})
      viewModel!.currentMonthReceiver.onNext(currentMonth)
      waitOnMainThread(waitDuration!)

      /// Then
      let lastIndex = indexObs.nextElements().last!
      XCTAssertEqual(lastIndex, index ?? prevIndex)
      prevIndex = lastIndex
    }
  }
}

extension MonthSectionTest: NNMonthSectionNoDefaultModelDependency {
  public var firstWeekday: Int {
    return firstWeekdayForTest!
  }

  public var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return allSelectionSb.mapObserver(Try.success)
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    return allSelectionSb.asObservable()
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
    return try! allSelectionSb.value()
      .map({$0.contains(where: {$0.contains(date)})})
      .getOrElse(false)
  }

  public func highlightPart(_ date: Date) -> NNCalendar.HighlightPart {
    return try! allSelectionSb.value()
      .map({NNCalendar.Util.highlightPart($0, date)})
      .getOrElse(.none)
  }
}
