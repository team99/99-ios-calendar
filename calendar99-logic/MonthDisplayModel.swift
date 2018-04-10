//
//  MonthDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month display model.
public protocol C99MonthDisplayModelDependency: C99MonthDisplayFunctionality {

  /// Stream components.
  var componentStream: Observable<Calendar99.Components> { get }
}

/// Factory for month display model dependency.
public protocol C99MonthDisplayModelDependencyFactory {

  /// Create a month display model dependency.
  ///
  /// - Returns: A MonthDisplayModelDependency instance.
  func monthDisplayModelDependency() -> C99MonthDisplayModelDependency
}

/// Model for month display view.
public protocol C99MonthDisplayModelType: C99MonthDisplayModelDependency {

  /// Calculate a range of Date that is applicable to the current calendar
  /// components. The first element of the range is not necessarily the start
  /// of the month, but the first day of the week within which the month begins.
  ///
  /// - Parameter components: A Components instance.
  /// - Returns: An Array of Date.
  func calculateDateRange(_ components: Calendar99.Components) -> [Date]
}

public extension Calendar99.MonthDisplay {
  public final class Model: C99MonthDisplayModelType {
    public var columnCount: Int {
      return dependency.columnCount
    }

    public var rowCount: Int {
      return dependency.rowCount
    }

    public var componentStream: Observable<Calendar99.Components> {
      return dependency.componentStream
    }

    fileprivate let dependency: C99MonthDisplayModelDependency

    public init(_ dependency: C99MonthDisplayModelDependency) {
      self.dependency = dependency
    }

    public func calculateDateRange(_ components: Calendar99.Components) -> [Date] {
      return []
    }
  }
}
