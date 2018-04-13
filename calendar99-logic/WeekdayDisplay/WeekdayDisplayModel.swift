//
//  WeekdayDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the weekday model and its dependency, so that
/// the model can expose the same properties.
public protocol NNWeekdayDisplayModelFunctionality {

  /// Get the description for a weekday.
  ///
  /// - Parameter weekday: An Int value.
  /// - Returns: A String value.
  func weekdayDescription(_ weekday: Int) -> String
}

/// Dependency for weekday model.
public protocol NNWeekdayDisplayModelDependency: NNWeekdayDisplayModelFunctionality {}

/// Model for weekday display view.
public protocol NNWeekdayDisplayModelType: NNWeekdayDisplayModelFunctionality {}

// MARK: - Model.
public extension NNCalendar.WeekdayView {

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

// MARK: - NNWeekdayDisplayModelFunctionality
extension NNCalendar.WeekdayView.Model: NNWeekdayDisplayModelFunctionality {
  public func weekdayDescription(_ weekday: Int) -> String {
    return dependency.weekdayDescription(weekday)
  }
}

// MARK: - NNWeekdayDisplayModelType
extension NNCalendar.WeekdayView.Model: NNWeekdayDisplayModelType {}

// MARK: - Default dependency.
public extension NNCalendar.WeekdayView.Model {
  internal final class DefaultDependency: NNWeekdayDisplayModelDependency {
    func weekdayDescription(_ weekday: Int) -> String {
      let date = Calendar.current.date(bySetting: .weekday, value: weekday, of: Date())
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEE"
      return date.map({dateFormatter.string(from: $0)}).getOrElse("")
    }
  }
}
