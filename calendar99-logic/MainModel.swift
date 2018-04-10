//
//  Model.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for calendar model for main view.
public protocol Calendar99MainModelDependency: Calendar99MainFunctionalityType {

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

/// Factory for model dependency.
public protocol Calendar99MainModelDependencyFactory {

  /// Create a model dependency for main calendar view.
  ///
  /// - Returns: A Calendar99ModelDependency instance.
  func mainCalendarModelDependency() -> Calendar99MainModelDependency
}

/// Model for main calendar view. This handles API calls.
public protocol Calendar99MainModelType: Calendar99MainModelDependency {

  /// Calculate a new components based on a month offset.
  ///
  /// - Parameters:
  ///   - prevComps: The previous components.
  ///   - monthOffset: A month offset value.
  /// - Returns: A tuple of month and year.
  func newComponents(_ prevComps: Calendar99.Components, _ monthOffset: Int)
    -> Calendar99.Components?
}

public extension Calendar99.Main {

  /// Model implementation.
  public final class Model: Calendar99MainModelType {
    fileprivate let dependency: Calendar99MainModelDependency

    public var componentStream: Observable<Calendar99.Components> {
      return dependency.componentStream
    }

    public var initialComponentStream: Single<Calendar99.Components> {
      return dependency.initialComponentStream
    }

    public var componentReceiver: AnyObserver<Calendar99.Components> {
      return dependency.componentReceiver
    }

    public init(_ dependency: Calendar99MainModelDependency) {
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
