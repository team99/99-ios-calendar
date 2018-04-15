//
//  MonthSectionTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 15/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftUtilities
import XCTest
@testable import calendar99_logic

public final class MockMonthSectionModel: NNMonthSectionModelType {
  public var mockAllDateSelectionStream: Observable<Set<Date>>?

  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return model.allDateSelectionReceiver
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return mockAllDateSelectionStream ?? model.allDateSelectionStream
  }

  public var initialMonthStream: Single<NNCalendar.Month> {
    return model.initialMonthStream
  }

  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return model.currentMonthReceiver
  }

  public var currentMonthStream: Observable<NNCalendar.Month> {
    return model.currentMonthStream
  }

  private let model: NNMonthSectionModelType

  public init(_ model: NNMonthSectionModelType) {
    self.model = model
  }

  public func calculateGridSelection(_ monthComps: [NNCalendar.MonthComp],
                                     _ firstWeekday: Int,
                                     _ selection: Date)
    -> Set<NNCalendar.GridSelection>
  {
    return model.calculateGridSelection(monthComps, firstWeekday, selection)
  }

  public func isDateSelected(_ date: Date) -> Bool {
    return model.isDateSelected(date)
  }

  public func componentRange(_ currentMonth: NNCalendar.Month,
                             _ pastMonthCount: Int,
                             _ futureMonthCount: Int) -> [NNCalendar.Month] {
    return model.componentRange(currentMonth, pastMonthCount, futureMonthCount)
  }

  public func calculateDayFromFirstDate(_ month: NNCalendar.Month,
                                        _ firstWeekday: Int,
                                        _ firstDateOffset: Int)
    -> NNCalendar.Day?
  {
    return model.calculateDayFromFirstDate(month, firstWeekday, firstDateOffset)
  }
}

/// Tests for month section.
public final class MonthSectionTest: RootTest {
  fileprivate var model: MockMonthSectionModel!
  fileprivate var viewModel: NNCalendar.MonthSection.ViewModel!
  fileprivate var currentMonth: NNCalendar.Month!
  fileprivate var allDateSelectionSb: BehaviorSubject<Set<Date>>!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendar.Month>!
  fileprivate var defaultViewModelDp: NNMonthSectionViewModelDependency!

  override public func setUp() {
    super.setUp()
    model = MockMonthSectionModel(NNCalendar.MonthSection.Model(self))
    viewModel = NNCalendar.MonthSection.ViewModel(self, model!)
    currentMonth = NNCalendar.Month(Date())
    allDateSelectionSb = BehaviorSubject(value: Set())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
    defaultViewModelDp = NNCalendar.MonthSection.ViewModel.DefaultDependency(self)
  }
}

public extension MonthSectionTest {
  public func test_monthComponentStream_shouldEmitCorrectMonths() {
    /// Setup
    viewModel!.setupMonthSectionBindings()

    /// When
    let monthComps = try! viewModel!.monthCompStream.take(1).toBlocking().first()!

    /// Then
    let pastOffset = pastMonthCountFromCurrent
    let futureOffset = futureMonthCountFromCurrent
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
    let pastOffset = pastMonthCountFromCurrent
    let futureOffset = futureMonthCountFromCurrent * 2
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
      if wasSelected {
        XCTAssertFalse(viewModel!.isDateSelected(selectedDate!))
      } else if selectedDate != nil {
        XCTAssertTrue(isDateSelected(selectedDate!))
      }
    }
  }

  public func test_gridSelectionChanges_shouldWorkCorrectly() {
    /// Setup
    let selectionChangesObs = scheduler!.createObserver(Set<NNCalendar.GridSelection>.self)
    let allDateSelectionSb = PublishSubject<Set<Date>>()
    let rowCount = viewModel!.rowCount
    let columnCount = viewModel!.columnCount
    model.mockAllDateSelectionStream = allDateSelectionSb.asObservable()
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
      let previousChanges = selectionChangesObs.nextElements().last ?? []
      let wasSelected = previousChanges.contains(gridSelection)
      allDateSelectionSb.onNext(Set(arrayLiteral: selectedDay.date))
      waitOnMainThread(waitDuration!)

      /// Then
      let lastChanges = selectionChangesObs.nextElements().last!

      // Since we only extract differences, if the calculated date has already
      // been selected it should be skipped.
      if !wasSelected {
        XCTAssertTrue(lastChanges.contains(gridSelection))
      } else {
        XCTAssertFalse(lastChanges.contains(gridSelection))
      }
    }
  }
}

extension MonthSectionTest: NNMonthSectionNoDefaultModelDependency {
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
    return try! allDateSelectionSb.value().contains(date)
  }
}

extension MonthSectionTest: NNMonthSectionNoDefaultViewModelDependency {
  public var pastMonthCountFromCurrent: Int {
    return 100
  }

  public var futureMonthCountFromCurrent: Int {
    return 100
  }
}
