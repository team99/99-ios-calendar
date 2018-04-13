//
//  SingleDaySelectionTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftUtilities
import XCTest
@testable import calendar99_logic

/// Tests for single day selection view model.
public final class SingleDaySelectionTest: RootTest {
  fileprivate var model: NNCalendar.DaySelection.Model!
  fileprivate var viewModel: NNCalendar.DaySelection.ViewModel!
  fileprivate var allSelectionSb: BehaviorSubject<Set<Date>>!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.DaySelection.Model(self)
    viewModel = NNCalendar.DaySelection.ViewModel(model!)
    allSelectionSb = BehaviorSubject(value: [])
  }
}

public extension SingleDaySelectionTest {
  public func test_selectSingleDates_shouldUpdateAllSelectionsCorrectly() {
    /// Setup
    viewModel!.setupDaySelectionBindings()
    var previousSelected: Date?

    for _ in 0..<iterations! {
      /// When
      let duplicate = Bool.random() && previousSelected != nil
      var newSelected: Date

      if duplicate, let prevSelected = previousSelected {
        newSelected = prevSelected
        previousSelected = nil
      } else {
        newSelected = Date.random()!

        while newSelected == previousSelected {
          newSelected = Date.random()!
        }

        previousSelected = newSelected
      }

      viewModel!.dateSelectionReceiver.onNext(newSelected)

      /// Then
      XCTAssertNotEqual(viewModel.isDateSelected(newSelected), duplicate)
    }
  }
}

extension SingleDaySelectionTest: NNSingleDaySelectionModelDependency {
  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return allSelectionSb.asObserver()
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return allSelectionSb.asObservable()
  }

  public func isDateSelected(_ date: Date) -> Bool {
    return (try? allSelectionSb.value())?.contains(date) ?? false
  }
}
