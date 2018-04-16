//
//  SelectHighlightTest.swift
//  calendar99-logicTests
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import calendar99_logic

/// Tests for selection highlight.
public final class SelectHighlightTest: RootTest {
  fileprivate var viewModel: NNCalendar.SelectHighlight.ViewModel!
  fileprivate var defaultViewModelDp: NNSelectHighlightViewModelDependency!

  override public func setUp() {
    super.setUp()
    viewModel = NNCalendar.SelectHighlight.ViewModel()
    defaultViewModelDp = NNCalendar.SelectHighlight.ViewModel.DefaultDependency()
  }
}

public extension SelectHighlightTest {
  public func test_defaultDependencies_shouldWork() {
    let viewModel1 = NNCalendar.SelectHighlight.ViewModel(defaultViewModelDp!)
    XCTAssertEqual(viewModel.rowCount, viewModel1.rowCount)
    XCTAssertEqual(viewModel.columnCount, viewModel1.columnCount)
  }
}
