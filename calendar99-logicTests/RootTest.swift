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
@testable import calendar99_logic

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

public extension RootTest {
  public var minimumMonth: NNCalendar.Month {
    return NNCalendar.Month(1, 1970)
  }

  public var maximumMonth: NNCalendar.Month {
    return NNCalendar.Month(12, 3000)
  }
}
