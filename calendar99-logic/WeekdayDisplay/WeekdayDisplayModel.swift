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
  NNWeekdayAwareDefaultModelFunction,
  NNWeekdayDisplayDefaultFunction
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
  NNWeekdayAwareNoDefaultModelFunction,
  NNWeekdayDisplayNoDefaultFunction {}

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

// MARK: - NNWeekdayDisplayDefaultFunction
extension NNCalendar.WeekdayDisplay.Model: NNWeekdayDisplayDefaultFunction {
  public var weekdayCount: Int {
    return dependency.weekdayCount
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
extension NNCalendar.WeekdayDisplay.Model {
  final class DefaultDependency: NNWeekdayDisplayModelDependency {
    var firstWeekday: Int { return weekdayAwareDp.firstWeekday }
    var weekdayCount: Int { return 7 }
    private let weekdayAwareDp: NNWeekdayAwareModelDependency

    init(_ dependency: NNWeekdayDisplayNoDefaultModelDependency) {
      weekdayAwareDp = NNCalendar.WeekdayAware.Model.DefaultDependency(dependency)
    }

    func weekdayDescription(_ weekday: Int) -> String {
      let date = Calendar.current.date(bySetting: .weekday, value: weekday, of: Date())
      let formatter = DateFormatter()
      formatter.dateFormat = "EEE"
      return date.map({formatter.string(from: $0).uppercased()}).getOrElse("")
    }
  }
}
