//
//  WeekdayAwareModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the model and its dependency.
public protocol NNWeekdayAwareModelFunction {

  /// Get the first day of a week (e.g. Monday).
  var firstWeekday: Int { get }
}

/// Dependency for weekday-aware model.
public protocol NNWeekdayAwareModelDependency: NNWeekdayAwareModelFunction {}

/// Model for weekday-aware views.
public protocol NNWeekdayAwareModelType: NNWeekdayAwareModelFunction {}

// MARK: - Model.
public extension NNCalendar.WeekdayAware {
  public final class Model {}
}

// MARK: - Default dependencies.
public extension NNCalendar.WeekdayAware.Model {

  /// Default dependency for weekday-aware view models.
  internal final class DefaultDependency: NNWeekdayAwareModelDependency {
    internal var firstWeekday: Int {
      return 1
    }
  }
}
