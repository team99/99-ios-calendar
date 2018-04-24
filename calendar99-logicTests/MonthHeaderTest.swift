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

extension MonthHeaderTest: MonthControlCommonTestProtocol {
  public func test_backwardAndForwardReceiver_shouldWork() {
    test_backwardAndForwardReceiver_shouldWork(viewModel!, model!)
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
    let viewModel1 = NNCalendar.MonthHeader.ViewModel(monthControlVM, model1)
    viewModel1.setupAllBindingsAndSubBindings()
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
      viewModel!.currentMonthReceiver.onNext(currentMonth)
      waitOnMainThread(waitDuration!)

      /// Then
      let monthDescription = model!.formatMonthDescription(currentMonth)
      let lastDescription = descObserver.nextElements().last!
      let lastMonth = monthObserver.nextElements().last!
      XCTAssertEqual(lastDescription, monthDescription)
      XCTAssertEqual(lastMonth, currentMonth)
    }
  }

  public func test_reachedMonthLimits_shouldEmitEvents() {
    /// Setup
    let minObs = scheduler!.createObserver(Bool.self)
    let maxObs = scheduler!.createObserver(Bool.self)
    let minMonth = model!.minimumMonth
    let maxMonth = model!.maximumMonth
    viewModel!.reachedMinimumMonth.subscribe(minObs).disposed(by: disposable!)
    viewModel!.reachedMaximumMonth.subscribe(maxObs).disposed(by: disposable!)
    viewModel!.setupMonthControlBindings()

    let testMonths = [currentMonth!,
                      currentMonth!,
                      minMonth,
                      minMonth,
                      currentMonth!,
                      currentMonth!,
                      maxMonth,
                      maxMonth]

    /// When
    for testMonth in testMonths {
      viewModel!.currentMonthReceiver.onNext(testMonth)
      waitOnMainThread(waitDuration!)
    }

    /// Then
    XCTAssertEqual(minObs.nextElements(), [false, true, false])
    XCTAssertEqual(maxObs.nextElements(), [false, true])
  }
}

extension MonthHeaderTest: NNMonthHeaderModelDependency {
  public var initialMonthStream: Single<NNCalendar.Month> {
    return currentMonthSb.take(1).asSingle()
  }

  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return currentMonthSb.asObserver()
  }

  public var currentMonthStream: Observable<NNCalendar.Month> {
    return currentMonthSb.asObservable()
  }

  public func formatMonthDescription(_ month: NNCalendar.Month) -> String {
    return String(describing: month)
  }
}
