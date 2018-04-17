//
//  WeekdayAwareModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the model and its dependency that can have
/// defaults.
public protocol NNWeekdayAwareDefaultModelFunction {

  /// Get the first day of a week (e.g. Monday).
  var firstWeekday: Int { get }
}

/// Shared functionalities between the model and its dependency that cannot
/// have defaults.
public protocol NNWeekdayAwareNoDefaultModelFunction {}

/// Dependency for weekday-aware model.
public protocol NNWeekdayAwareModelDependency:
  NNWeekdayAwareDefaultModelFunction,
  NNWeekdayAwareNoDefaultModelFunction {}

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
  internal final class DefaultDependency: NNWeekdayAwareModelDependency {
    internal var firstWeekday: Int { return 1 }
  }
}
