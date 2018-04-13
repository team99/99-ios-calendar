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
  var firstDayOfWeek: Int { get }
}
