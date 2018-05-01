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
  fileprivate var model: NNCalendarLogic.MonthHeader.Model!
  fileprivate var viewModel: NNCalendarLogic.MonthHeader.ViewModel!
  fileprivate var currentMonth: NNCalendarLogic.Month!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendarLogic.Month>!

  override public func setUp() {
    super.setUp()
    model = NNCalendarLogic.MonthHeader.Model(self)
    viewModel = NNCalendarLogic.MonthHeader.ViewModel(model)
    currentMonth = NNCalendarLogic.Month(Date())
    currentMonthSb = BehaviorSubject(value: currentMonth!)
  }
}

extension MonthHeaderTest: MonthControlCommonTestProtocol {
  public func test_backwardAndForwardReceiver_shouldWork() {
    test_backwardAndForwardReceiver_shouldWork(viewModel!, model!)
  }

  public func test_minAndMaxMonths_shouldLimitMonthSelection() {
    test_minAndMaxMonths_shouldLimitMonthSelection(viewModel!, model!)
  }
}

public extension MonthHeaderTest {
  public func test_multipleConstructors_shouldWork() {
    let monthControlModel = NNCalendarLogic.MonthControl.Model(self)
    let model1 = NNCalendarLogic.MonthHeader.Model(monthControlModel, self)
    
    XCTAssertEqual(model!.formatMonthDescription(currentMonth!),
                   model1.formatMonthDescription(currentMonth!))

    let monthControlVM = NNCalendarLogic.MonthControl.ViewModel(monthControlModel)
    let viewModel1 = NNCalendarLogic.MonthHeader.ViewModel(monthControlVM, model1)
    viewModel1.setupAllBindingsAndSubBindings()
  }

  public func test_monthDescriptionStream_shouldEmitCorrectDescriptions() {
    /// Setup
    let descObs = scheduler!.createObserver(String.self)
    let monthObs = scheduler!.createObserver(NNCalendarLogic.Month.self)
    var currentMonth = self.currentMonth!

    // Subscribe to the month component and month description streams to test
    // that all elements are emitted correctly.
    model!.currentMonthStream.subscribe(monthObs).disposed(by: disposable)
    viewModel!.monthDescriptionStream.subscribe(descObs).disposed(by: disposable!)
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
      let lastDescription = descObs.nextElements().last!
      let lastMonth = monthObs.nextElements().last!
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
  public var initialMonthStream: Single<NNCalendarLogic.Month> {
    return currentMonthSb.take(1).asSingle()
  }

  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return currentMonthSb.asObserver()
  }

  public var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return currentMonthSb.asObservable()
  }

  public func formatMonthDescription(_ month: NNCalendarLogic.Month) -> String {
    return NNCalendarLogic.Util.defaultMonthDescription(month)
  }
}
