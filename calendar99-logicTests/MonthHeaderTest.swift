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
  fileprivate var currentMonthComp: NNCalendar.MonthComp!
  fileprivate var currentMonthSb: BehaviorSubject<NNCalendar.MonthComp>!

  override public func setUp() {
    super.setUp()
    model = NNCalendar.MonthHeader.Model(self as NNMonthHeaderNoDefaultModelDependency)
    viewModel = NNCalendar.MonthHeader.ViewModel(model)
    currentMonthComp = NNCalendar.MonthComp(Date())
    currentMonthSb = BehaviorSubject(value: currentMonthComp!)
  }
}

public extension MonthHeaderTest {
  public func test_multipleConstructors_shouldWork() {
    let monthControlModel = NNCalendar.MonthControl.Model(self)
    let model1 = NNCalendar.MonthHeader.Model(monthControlModel, self)
    let model2 = NNCalendar.MonthHeader.Model(self)
    
    XCTAssertEqual(model1.formatMonthDescription(currentMonthComp!),
                   model2.formatMonthDescription(currentMonthComp!))

    let monthControlVM = NNCalendar.MonthControl.ViewModel(monthControlModel)
    _ = NNCalendar.MonthHeader.ViewModel(monthControlVM, model1)
  }

  public func test_monthDescriptionStream_shouldEmitCorrectDescriptions() {
    /// Setup
    let descObserver = testScheduler!.createObserver(String.self)
    let compObserver = testScheduler!.createObserver(NNCalendar.MonthComp.self)
    var currentComp = self.currentMonthComp
    var descriptions = [String]()
    var monthComps = [NNCalendar.MonthComp]()
    descriptions.append(model.formatMonthDescription(currentComp!))
    monthComps.append(currentComp!)

    // Subscribe to the month component and month description streams to test
    // that all elements are emitted correctly.
    model!.currentMonthCompStream
      .subscribe(compObserver)
      .disposed(by: disposable)

    viewModel!.monthDescriptionStream
      .subscribe(descObserver)
      .disposed(by: disposable!)

    viewModel!.setupAllBindingsAndSubBindings()

    /// When
    for _ in 0..<iterations! {
      let forward = Bool.random()
      let jump = Int.random(0, 1000)
      currentComp = currentComp!.with(monthOffset: forward ? jump : -jump)
      descriptions.append(model.formatMonthDescription(currentComp!))
      monthComps.append(currentComp!)

      if forward {
        viewModel!.currentMonthForwardReceiver.onNext(UInt(jump))
      } else {
        viewModel!.currentMonthBackwardReceiver.onNext(UInt(jump))
      }
    }

    /// Then
    XCTAssertEqual(Set(descObserver.nextElements()), Set(descriptions))
    XCTAssertEqual(Set(compObserver.nextElements()), Set(monthComps))
  }
}

extension MonthHeaderTest: NNMonthHeaderModelDependency {
  public var currentMonthCompReceiver: AnyObserver<NNCalendar.MonthComp> {
    return currentMonthSb.asObserver()
  }

  public var currentMonthCompStream: Observable<NNCalendar.MonthComp> {
    return currentMonthSb.asObservable()
  }

  public func formatMonthDescription(_ comps: NNCalendar.MonthComp) -> String {
    return comps.description
  }
}
