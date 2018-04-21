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
  public var scheduler: TestScheduler!
  public var disposable: DisposeBag!
  public var firstWeekdayForTest: Int!
  public var iterations: Int!
  public var waitDuration: TimeInterval!

  override public func setUp() {
    super.setUp()
    scheduler = TestScheduler(initialClock: 0)
    disposable = DisposeBag()
    firstWeekdayForTest = 5
    iterations = 1000
    waitDuration = 0
    continueAfterFailure = false
  }
}

extension RootTest: CommonTestProtocol {}
