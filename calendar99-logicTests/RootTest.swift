//
//  RootTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest

/// Root tests.
public class RootTest: XCTestCase {
  public var iterations: Int!
  public var waitDuration: TimeInterval!
  public var firstDayOfWeek: Int!

  override public func setUp() {
    super.setUp()
    iterations = 1000
    waitDuration = 0.2
    firstDayOfWeek = 2
    continueAfterFailure = false
  }
}
