//
//  WeekdayAwareViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Dependency for weekday-aware view model.
public protocol NNWeekdayAwareViewModelDependency {

  /// Get the first day of a week (e.g. Monday).
  var firstWeekday: Int { get }
}

// MARK: - View model.
public extension NNCalendar.WeekdayAware {
  public final class ViewModel {}
}

// MARK: - Default dependencies.
public extension NNCalendar.WeekdayAware.ViewModel {

  /// Default dependency for weekday-aware view models.
  internal final class DefaultDependency: NNWeekdayAwareViewModelDependency {
    internal var firstWeekday: Int {
      return 1
    }
  }
}
