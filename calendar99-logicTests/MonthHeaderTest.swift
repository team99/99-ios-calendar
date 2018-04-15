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
    let descObserver = testScheduler!.createObserver(String.self)
    let monthObserver = testScheduler!.createObserver(NNCalendar.Month.self)
    var currentMonth = self.currentMonth
    var descriptions = [String]()
    var months = [NNCalendar.Month]()
    descriptions.append(model.formatMonthDescription(currentMonth!))
    months.append(currentMonth!)

    // Subscribe to the month component and month description streams to test
    // that all elements are emitted correctly.
    model!.currentMonthStream
      .subscribe(monthObserver)
      .disposed(by: disposable)

    viewModel!.monthDescriptionStream
      .subscribe(descObserver)
      .disposed(by: disposable!)

    viewModel!.setupAllBindingsAndSubBindings()

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      let jump = Int.random(0, 1000)
      currentMonth = currentMonth!.with(monthOffset: forward ? jump : -jump)
      descriptions.append(model.formatMonthDescription(currentMonth!))
      months.append(currentMonth!)

      if forward {
        viewModel!.currentMonthForwardReceiver.onNext(UInt(jump))
      } else {
        viewModel!.currentMonthBackwardReceiver.onNext(UInt(jump))
      }
    }

    /// Then
    XCTAssertEqual(Set(descObserver.nextElements()), Set(descriptions))
    XCTAssertEqual(Set(monthObserver.nextElements()), Set(months))
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
