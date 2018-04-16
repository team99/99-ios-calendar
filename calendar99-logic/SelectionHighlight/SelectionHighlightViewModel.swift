//
//  SelectionHighlightViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the view model and dependency for selection
/// highlight view.
public protocol NNSelectHighlightViewModelFunction:
  NNGridDisplayViewModelFunction {}

/// Dependency for selection highlight view model.
public protocol NNSelectHighlightViewModelDependency:
  NNSelectHighlightViewModelFunction,
  NNMGridDisplayViewModelDependency {}

/// View model for selection highlight view.
public protocol NNSelectHighlightViewModelType:
  NNSelectHighlightViewModelFunction,
  NNGridDisplayViewModelType {}

// MARK: - View model.
public extension NNCalendar.SelectHighlight {

  /// View model for selection highlight view.
  public final class ViewModel {
    fileprivate let dependency: NNSelectHighlightViewModelDependency

    required public init(_ dependency: NNSelectHighlightViewModelDependency) {
      self.dependency = dependency
    }

    convenience public init() {
      let defaultDp = DefaultDependency()
      self.init(defaultDp)
    }
  }
}

// MARK: - NNGridDisplayViewModelType
extension NNCalendar.SelectHighlight.ViewModel: NNGridDisplayViewModelType {
  public var columnCount: Int {
    return dependency.columnCount
  }

  public var rowCount: Int {
    return dependency.rowCount
  }
}

// MARK: - NNSelectionHighlightViewModelType
extension NNCalendar.SelectHighlight.ViewModel: NNSelectHighlightViewModelType {}

// MARK: - Default dependency.
public extension NNCalendar.SelectHighlight.ViewModel {

  /// Default dependency for selection highlight view model.
  internal final class DefaultDependency: NNSelectHighlightViewModelDependency {
    internal var columnCount: Int {
      return gridDisplayDp.columnCount
    }

    internal var rowCount: Int {
      return gridDisplayDp.rowCount
    }

    private let gridDisplayDp: NNMGridDisplayViewModelDependency

    internal init() {
      gridDisplayDp = NNCalendar.GridDisplay.ViewModel.DefaultDependency()
    }
  }
}
