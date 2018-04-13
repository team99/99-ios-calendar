//
//  RootTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import XCTest

/// Root tests.
public class RootTest: XCTestCase {
  public var iterations: Int!
  public var waitDuration: TimeInterval!
  public var firstWeekDay: Int!
  public var disposable: DisposeBag!

  override public func setUp() {
    super.setUp()
    iterations = 1000
    waitDuration = 0.2
    firstWeekDay = 2
    disposable = DisposeBag()
    continueAfterFailure = false
  }
}
