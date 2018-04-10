//
//  Model.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month header model.
public protocol C99MonthHeaderModelDependency: C99MonthHeaderFunctionality {

  /// Stream the current selected components.
  var componentStream: Observable<Calendar99.Components> { get }

  /// Emit the initial components.
  var initialComponentStream: Single<Calendar99.Components> { get }

  /// Receive the current components.
  var componentReceiver: AnyObserver<Calendar99.Components> { get }

  /// Format month description.
  ///
  /// - Parameter components: A ControlComponents instance.
  /// - Returns: A String value.
  func formatMonthDescription(_ components: Calendar99.Components) -> String
}

/// Factory for month header model dependency.
public protocol C99MonthHeaderDependencyFactory {

  /// Create a model dependency for month header view.
  ///
  /// - Returns: A Calendar99ModelDependency instance.
  func monthHeaderModelDependency() -> C99MonthHeaderModelDependency
}

/// Model for month header view.
public protocol C99MonthHeaderModelType: C99MonthHeaderModelDependency {

  /// Calculate a new components based on a month offset.
  ///
  /// - Parameters:
  ///   - prevComps: The previous components.
  ///   - monthOffset: A month offset value.
  /// - Returns: A tuple of month and year.
  func newComponents(_ prevComps: Calendar99.Components, _ monthOffset: Int)
    -> Calendar99.Components?
}

public extension Calendar99.MonthHeader {

  /// Model implementation.
  public final class Model: C99MonthHeaderModelType {
    fileprivate let dependency: C99MonthHeaderModelDependency

    public var componentStream: Observable<Calendar99.Components> {
      return dependency.componentStream
    }

    public var initialComponentStream: Single<Calendar99.Components> {
      return dependency.initialComponentStream
    }

    public var componentReceiver: AnyObserver<Calendar99.Components> {
      return dependency.componentReceiver
    }

    public init(_ dependency: C99MonthHeaderModelDependency) {
      self.dependency = dependency
    }

    public func formatMonthDescription(_ components: Calendar99.Components) -> String {
      return dependency.formatMonthDescription(components)
    }

    public func newComponents(_ prevComponents: Calendar99.Components,
                              _ monthOffset: Int) -> Calendar99.Components? {
      let prevMonth = prevComponents.month
      let prevYear = prevComponents.year

      return Calendar99.DateUtil
        .newMonthAndYear(prevMonth, prevYear, monthOffset)
        .map({Calendar99.Components(month: $0.month, year: $0.year)})
    }
  }
}
