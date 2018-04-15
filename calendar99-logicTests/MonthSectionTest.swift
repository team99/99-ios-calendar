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

/// Tests for month section.
public final class MonthSectionTest: RootTest {
  fileprivate var model: NNCalendar.MonthSection.Model!
  fileprivate var viewModel: NNCalendar.MonthSection.ViewModel!
  fileprivate var currentMonth: NNCalendar.Month!
  fileprivate var allDateSelectionSb: BehaviorSubject<Set<Date>>!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendar.Month>!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.MonthSection.Model(self)
    viewModel = NNCalendar.MonthSection.ViewModel(self, model!)
    currentMonth = NNCalendar.Month(Date())
    allDateSelectionSb = BehaviorSubject(value: Set())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
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

      let dayIndex = Int.random(0, rowCount * columnCount)
      let selection = NNCalendar.GridSelection(monthIndex: offset, dayIndex: dayIndex)
      let withinRange = offset < months.count
      viewModel!.gridSelectionReceiver.onNext(selection)
      let selectedDate = withinRange ? months[offset] : nil
      print(selectedDate)

      /// Then

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
    return 1000
  }

  public var futureMonthCountFromCurrent: Int {
    return 1000
  }
}
