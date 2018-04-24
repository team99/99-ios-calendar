//
//  WeekdayAwareModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the model and its dependency that can have
/// defaults.
public protocol NNWeekdayAwareDefaultModelFunction {}

/// Shared functionalities between the model and its dependency that cannot
/// have defaults.
public protocol NNWeekdayAwareNoDefaultModelFunction {

  /// Get the first day of a week (e.g. Monday).
  var firstWeekday: Int { get }
}

/// Defaultable dependency for weekday-aware model.
public protocol NNWeekdayAwareDefaultModelDependency:
  NNWeekdayAwareDefaultModelFunction {}

/// Non-defaultable dependency for weekday-aware model.
public protocol NNWeekdayAwareNoDefaultModelDependency:
  NNWeekdayAwareNoDefaultModelFunction {}

/// Dependency for weekday-aware model.
public protocol NNWeekdayAwareModelDependency:
  NNWeekdayAwareDefaultModelDependency,
  NNWeekdayAwareNoDefaultModelDependency {}

/// Model for weekday-aware views.
public protocol NNWeekdayAwareModelType:
  NNWeekdayAwareDefaultModelFunction,
  NNWeekdayAwareNoDefaultModelFunction {}

// MARK: - Model.
public extension NNCalendar.WeekdayAware {
  public final class Model {}
}

// MARK: - Default dependencies.
public extension NNCalendar.WeekdayAware.Model {

  /// Default dependency for weekday-aware view models.
  public final class DefaultDependency: NNWeekdayAwareModelDependency {
    public var firstWeekday: Int { return noDefault.firstWeekday }
    private let noDefault: NNWeekdayAwareNoDefaultModelDependency

    public init(_ dependency: NNWeekdayAwareNoDefaultModelDependency) {
      noDefault = dependency
    }
  }
}
