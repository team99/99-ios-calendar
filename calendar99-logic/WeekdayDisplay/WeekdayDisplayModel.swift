//
//  WeekdayDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the weekday model and its dependency that
/// can have defaults.
public protocol NNWeekdayDisplayDefaultModelFunction:
  NNWeekdayAwareDefaultModelFunction
{
  /// Get the description for a weekday.
  ///
  /// - Parameter weekday: An Int value.
  /// - Returns: A String value.
  func weekdayDescription(_ weekday: Int) -> String
}

/// Shared functionalities between the weekday model and its dependency that
/// cannot have defaults.
public protocol NNWeekdayDisplayNoDefaultModelFunction:
  NNWeekdayAwareNoDefaultModelFunction {}

/// Defaultable dependency for weekday model.
public protocol NNWeekdayDisplayDefaultModelDependency:
  NNWeekdayAwareDefaultModelDependency,
  NNWeekdayDisplayDefaultModelFunction {}

/// Non-defaultable dependency for weekday model.
public protocol NNWeekdayDisplayNoDefaultModelDependency:
  NNWeekdayAwareNoDefaultModelDependency,
  NNWeekdayDisplayNoDefaultModelFunction {}

/// Dependency for weekday model.
public protocol NNWeekdayDisplayModelDependency:
  NNWeekdayDisplayDefaultModelDependency,
  NNWeekdayDisplayNoDefaultModelDependency {}

/// Model for weekday display view.
public protocol NNWeekdayDisplayModelType:
  NNWeekdayAwareModelType,
  NNWeekdayDisplayDefaultModelFunction,
  NNWeekdayDisplayNoDefaultModelFunction {}

// MARK: - Model.
public extension NNCalendar.WeekdayDisplay {

  /// Model implementation.
  public final class Model {
    fileprivate let dependency: NNWeekdayDisplayModelDependency

    required public init(_ dependency: NNWeekdayDisplayModelDependency) {
      self.dependency = dependency
    }

    convenience public init(_ dependency: NNWeekdayDisplayNoDefaultModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }
  }
}

// MARK: - NNWeekdayAwareDefaultModelFunction
extension NNCalendar.WeekdayDisplay.Model: NNWeekdayAwareDefaultModelFunction {
  public var firstWeekday: Int {
    return dependency.firstWeekday
  }
}

// MARK: - NNWeekdayDisplayModelFunction
extension NNCalendar.WeekdayDisplay.Model: NNWeekdayDisplayDefaultModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return dependency.weekdayDescription(weekday)
  }
}

// MARK: - NNWeekdayDisplayModelType
extension NNCalendar.WeekdayDisplay.Model: NNWeekdayDisplayModelType {}

// MARK: - Default dependency.
public extension NNCalendar.WeekdayDisplay.Model {
  public final class DefaultDependency: NNWeekdayDisplayModelDependency {
    public var firstWeekday: Int { return weekdayAwareDp.firstWeekday }
    private let weekdayAwareDp: NNWeekdayAwareModelDependency

    public init(_ dependency: NNWeekdayDisplayNoDefaultModelDependency) {
      weekdayAwareDp = NNCalendar.WeekdayAware.Model.DefaultDependency(dependency)
    }

    public func weekdayDescription(_ weekday: Int) -> String {
      return NNCalendar.Util.defaultWeekdayDescription(weekday)
    }
  }
}
