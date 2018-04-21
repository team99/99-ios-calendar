//
//  SingleDaySelectionTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import SwiftUtilities
import XCTest
@testable import calendar99_logic

/// Tests for single day selection view model.
public final class SingleDaySelectionTest: RootTest {
  fileprivate var model: NNCalendar.DaySelection.Model!
  fileprivate var viewModel: NNCalendar.DaySelection.ViewModel!
  fileprivate var allSelectionSb: BehaviorSubject<Try<Set<NNCalendar.Selection>>>!
  fileprivate var defaultModelDp: NNCalendar.DaySelection.Model.DefaultDependency!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.DaySelection.Model(self)
    viewModel = NNCalendar.DaySelection.ViewModel(model!)
    allSelectionSb = BehaviorSubject(value: Try.failure(""))
    defaultModelDp = NNCalendar.DaySelection.Model.DefaultDependency(self)
  }
}

public extension SingleDaySelectionTest {
  public func test_defaultDependencies_shouldWork() {
    let model1 = NNCalendar.DaySelection.Model(defaultModelDp)
    XCTAssertEqual(model!.firstWeekday, model1.firstWeekday)
  }

  public func test_selectSingleDates_shouldUpdateAllSelectionsCorrectly() {
    /// Setup
    viewModel!.setupDaySelectionBindings()
    var previousSelected: Date?

    for _ in 0..<iterations! {
      /// When
      let duplicate = Bool.random() && previousSelected != nil
      var newSelected: Date?

      if duplicate, let prevSelected = previousSelected {
        newSelected = prevSelected
        previousSelected = nil
      } else {
        while newSelected == nil || newSelected == previousSelected {
          newSelected = Date.random()!
        }

        previousSelected = newSelected
      }

      viewModel!.dateSelectionReceiver.onNext(newSelected!)
      waitOnMainThread(waitDuration!)

      /// Then
      XCTAssertNotEqual(viewModel.isDateSelected(newSelected!), duplicate)
    }
  }
}

extension SingleDaySelectionTest: NNSingleDaySelectionNoDefaultModelDependency {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return allSelectionSb.mapObserver(Try.success)
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    return allSelectionSb.asObservable()
  }

  public func isDateSelected(_ date: Date) -> Bool {
    return try! allSelectionSb!.value()
      .map({$0.contains(where: {$0.contains(date)})})
      .getOrElse(false)
  }
}
