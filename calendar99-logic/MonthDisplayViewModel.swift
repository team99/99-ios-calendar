//
//  MonthDisplayViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month display view model.
public protocol C99MonthDisplayViewModelDependency {}

/// Factory for month display view model dependency.
public protocol C99MonthDisplayViewModelDependencyFactory {

  /// Create a month display view model dependency.
  ///
  /// - Returns: A Calendar99MonthDisplayViewModelDependency instance.
  func monthDisplayViewModelDependency() -> C99MonthDisplayViewModelDependency
}

/// View model for month display view.
public protocol C99MonthDisplayViewModelType: C99MonthDisplayFunctionality {

  /// Stream days.
  var dayStream: Observable<[Calendar99.Day]> { get }
}

public extension Calendar99.MonthDisplay {

  /// Month display view model implementation.
  public final class ViewModel: C99MonthDisplayViewModelType {
    public var columnCount: Int {
      return model.columnCount
    }

    public var rowCount: Int {
      return model.rowCount
    }

    public var dayStream: Observable<[Calendar99.Day]> {
      return model.componentStream
        .map({[weak self] in self?.model.calculateDateRange($0)})
        .filter({$0.isSome}).map({$0!})
        .map({$0.map({Calendar99.Day(date: $0)})})
    }

    fileprivate let dependency: C99MonthDisplayViewModelDependency
    fileprivate let model: C99MonthDisplayModelType

    public init(_ dependency: C99MonthDisplayViewModelDependency,
                _ model: C99MonthDisplayModelType) {
      self.dependency = dependency
      self.model = model
    }
  }
}
