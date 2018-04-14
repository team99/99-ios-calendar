//
//  RootTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import RxTest
import XCTest

/// Root tests.
public class RootTest: XCTestCase {
  public var testScheduler: TestScheduler!
  public var disposable: DisposeBag!
  public var iterations: Int!
  public var waitDuration: TimeInterval!
  public var firstWeekDay: Int!

  override public func setUp() {
    super.setUp()
    testScheduler = TestScheduler(initialClock: 0)
    disposable = DisposeBag()
    iterations = 1000
    waitDuration = 0.2
    firstWeekDay = 2
    continueAfterFailure = false
  }
}
