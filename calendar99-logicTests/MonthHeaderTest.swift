//
//  MonthHeaderTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 14/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import RxTest
import SwiftFP
import SwiftUtilities
import XCTest
@testable import calendar99_logic

/// Tests for month header.
public final class MonthHeaderTest: RootTest {
  fileprivate var model: NNCalendar.MonthHeader.Model!
  fileprivate var viewModel: NNCalendar.MonthHeader.ViewModel!
  fileprivate var currentMonth: NNCalendar.Month!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendar.Month>!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.MonthHeader.Model(self as NNMonthHeaderNoDefaultModelDependency)
    viewModel = NNCalendar.MonthHeader.ViewModel(model)
    currentMonth = NNCalendar.Month(Date())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
  }
}

public extension MonthHeaderTest {
  public func test_multipleConstructors_shouldWork() {
    let monthControlModel = NNCalendar.MonthControl.Model(self)
    let model1 = NNCalendar.MonthHeader.Model(monthControlModel, self)
    let model2 = NNCalendar.MonthHeader.Model(self)
    
    XCTAssertEqual(model1.formatMonthDescription(currentMonth!),
                   model2.formatMonthDescription(currentMonth!))

    let monthControlVM = NNCalendar.MonthControl.ViewModel(monthControlModel)
    _ = NNCalendar.MonthHeader.ViewModel(monthControlVM, model1)
  }

  public func test_monthDescriptionStream_shouldEmitCorrectDescriptions() {
    /// Setup
    let descObserver = scheduler!.createObserver(String.self)
    let monthObserver = scheduler!.createObserver(NNCalendar.Month.self)
    var currentMonth = self.currentMonth!

    // Subscribe to the month component and month description streams to test
    // that all elements are emitted correctly.
    model!.currentMonthStream
      .subscribe(monthObserver)
      .disposed(by: disposable)

    viewModel!.monthDescriptionStream
      .subscribe(descObserver)
      .disposed(by: disposable!)

    viewModel!.setupMonthControlBindings()

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      let jump = Int.random(0, 1000)
      currentMonth = currentMonth.with(monthOffset: forward ? jump : -jump)!
      let monthDescription = model!.formatMonthDescription(currentMonth)

      if forward {
        viewModel!.currentMonthForwardReceiver.onNext(UInt(jump))
      } else {
        viewModel!.currentMonthBackwardReceiver.onNext(UInt(jump))
      }

      waitOnMainThread(waitDuration!)

      /// Then
      let lastDescription = descObserver.nextElements().last!
      let lastMonth = monthObserver.nextElements().last!
      XCTAssertEqual(lastDescription, monthDescription)
      XCTAssertEqual(lastMonth, currentMonth)
    }
  }
}

extension MonthHeaderTest: NNMonthHeaderModelDependency {
  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return currentMonthSb.asObserver()
  }

  public var currentMonthStream: Observable<NNCalendar.Month> {
    return currentMonthSb.asObservable()
  }

  public func formatMonthDescription(_ month: NNCalendar.Month) -> String {
    return month.description
  }
}
