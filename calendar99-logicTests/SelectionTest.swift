//
//  SelectionTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 19/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import calendar99_logic

/// Tests for selection object.
public final class SelectionTest: RootTest {}

public extension SelectionTest {
  public func test_defaultSelection_shouldBeTheSame() {
    /// Setup
    let selection1 = NNCalendar.Selection()
    let selection2 = NNCalendar.Selection()

    /// When & Then
    XCTAssertEqual(selection1, selection2)
    XCTAssertEqual(selection1.hashValue, selection2.hashValue)

    XCTAssertEqual(selection1.isDateSelected(Date.random()!),
                   selection2.isDateSelected(Date.random()!))

    XCTAssertEqual(selection1.calculateGridSelection([]),
                   selection2.calculateGridSelection([]))
  }
}
