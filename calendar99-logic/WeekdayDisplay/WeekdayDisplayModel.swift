//
//  WeekdayDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the weekday model and its dependency.
public protocol NNWeekdayDisplayModelFunction: NNWeekdayAwareModelFunction {
  
  /// Get the description for a weekday.
  ///
  /// - Parameter weekday: An Int value.
  /// - Returns: A String value.
  func weekdayDescription(_ weekday: Int) -> String
}

/// Dependency for weekday model.
public protocol NNWeekdayDisplayModelDependency:
  NNWeekdayAwareModelDependency,
  NNWeekdayDisplayModelFunction {}

/// Model for weekday display view.
public protocol NNWeekdayDisplayModelType:
  NNWeekdayAwareModelType,
  NNWeekdayDisplayModelFunction {}

// MARK: - Model.
public extension NNCalendarLogic.WeekdayDisplay {

  /// Model implementation.
  public final class Model {
    fileprivate let dependency: NNWeekdayDisplayModelDependency

    required public init(_ dependency: NNWeekdayDisplayModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - NNWeekdayAwareModelFunction
extension NNCalendarLogic.WeekdayDisplay.Model: NNWeekdayAwareModelFunction {
  public var firstWeekday: Int {
    return dependency.firstWeekday
  }
}

// MARK: - NNWeekdayDisplayModelFunction
extension NNCalendarLogic.WeekdayDisplay.Model: NNWeekdayDisplayModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return dependency.weekdayDescription(weekday)
  }
}

// MARK: - NNWeekdayDisplayModelType
extension NNCalendarLogic.WeekdayDisplay.Model: NNWeekdayDisplayModelType {}
