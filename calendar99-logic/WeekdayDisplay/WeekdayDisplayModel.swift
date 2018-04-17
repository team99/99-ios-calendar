//
//  WeekdayDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the weekday model and its dependency, so that
/// the model can expose the same properties.
public protocol NNWeekdayDisplayModelFunction:
  NNWeekdayDisplayFunction,
  NNWeekdayAwareModelFunction
{
  /// Get the description for a weekday.
  ///
  /// - Parameter weekday: An Int value.
  /// - Returns: A String value.
  func weekdayDescription(_ weekday: Int) -> String
}

/// Dependency for weekday model.
public protocol NNWeekdayDisplayModelDependency: NNWeekdayDisplayModelFunction {}

/// Model for weekday display view.
public protocol NNWeekdayDisplayModelType:
  NNWeekdayDisplayModelFunction,
  NNWeekdayAwareModelType {}

// MARK: - Model.
public extension NNCalendar.WeekdayDisplay {

  /// Model implementation.
  public final class Model {
    fileprivate let dependency: NNWeekdayDisplayModelDependency

    required public init(_ dependency: NNWeekdayDisplayModelDependency) {
      self.dependency = dependency
    }

    convenience public init() {
      let defaultDp = DefaultDependency()
      self.init(defaultDp)
    }
  }
}

// MARK: - NNWeekdayDisplayFunction
extension NNCalendar.WeekdayDisplay.Model: NNWeekdayDisplayFunction {
  public var weekdayCount: Int {
    return dependency.weekdayCount
  }
}

// MARK: - NNWeekdayAwareModelFunction
extension NNCalendar.WeekdayDisplay.Model: NNWeekdayAwareModelFunction {
  public var firstWeekday: Int {
    return dependency.firstWeekday
  }
}

// MARK: - NNWeekdayDisplayModelFunction
extension NNCalendar.WeekdayDisplay.Model: NNWeekdayDisplayModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return dependency.weekdayDescription(weekday)
  }
}

// MARK: - NNWeekdayDisplayModelType
extension NNCalendar.WeekdayDisplay.Model: NNWeekdayDisplayModelType {}

// MARK: - Default dependency.
public extension NNCalendar.WeekdayDisplay.Model {
  internal final class DefaultDependency: NNWeekdayDisplayModelDependency {
    internal var firstWeekday: Int {
      return weekdayAwareDp.firstWeekday
    }

    internal var weekdayCount: Int {
      return 7
    }

    private let weekdayAwareDp: NNWeekdayAwareModelDependency

    internal init() {
      weekdayAwareDp = NNCalendar.WeekdayAware.Model.DefaultDependency()
    }

    internal func weekdayDescription(_ weekday: Int) -> String {
      let date = Calendar.current.date(bySetting: .weekday, value: weekday, of: Date())
      let formatter = DateFormatter()
      formatter.dateFormat = "EEE"
      return date.map({formatter.string(from: $0).uppercased()}).getOrElse("")
    }
  }
}
