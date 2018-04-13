//
//  SelectableWeekdayDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency.
public protocol NNSelectableWeekdayModelFunctionality:
  NNWeekdayDisplayModelFunctionality,
  NNMonthAwareModelFunctionality {}

/// Dependency for selectable weekday display whose components cannot have
/// defaults.
public protocol NNSelectableWeekdayNonDefaultableModelDependency:
  NNMonthAwareModelDependency {}

/// Dependency for selectable weekday display.
public protocol NNSelectableWeekdayModelDependency:
  NNSelectableWeekdayModelFunctionality,
  NNWeekdayDisplayModelDependency,
  NNSelectableWeekdayNonDefaultableModelDependency {}

/// Model for selectable weekday display.
public protocol NNSelectableWeekdayModelType:
  NNSelectableWeekdayModelFunctionality,
  NNWeekdayDisplayModelType {}

// MARK: - Model.
public extension NNCalendar.SelectableWeekday {

  /// Model implementation.
  public final class Model {
    fileprivate let weekdayModel: NNWeekdayDisplayModelType
    fileprivate let dependency: NNSelectableWeekdayModelDependency

    public init(_ weekdayModel: NNWeekdayDisplayModelType,
                _ dependency: NNSelectableWeekdayModelDependency) {
      self.weekdayModel = weekdayModel
      self.dependency = dependency
    }
  }
}

// MARK: - NNMonthAwareModelFunctionality
extension NNCalendar.SelectableWeekday.Model: NNWeekdayDisplayModelFunctionality {
  public func weekdayDescription(_ weekday: Int) -> String {
    return weekdayModel.weekdayDescription(weekday)
  }
}

// MARK: - NNMonthAwareModelFunctionality
extension NNCalendar.SelectableWeekday.Model: NNMonthAwareModelFunctionality {
  public var currentMonthCompStream: Observable<NNCalendar.MonthComp> {
    return dependency.currentMonthCompStream
  }
}

// MARK: - NNSelectableWeekdayModelType
extension NNCalendar.SelectableWeekday.Model: NNSelectableWeekdayModelType {}

// MARK: - Default dependency.
public extension NNCalendar.SelectableWeekday.Model {
  internal final class DefaultDependency: NNSelectableWeekdayModelDependency {
    internal var currentMonthCompStream: Observable<NNCalendar.MonthComp> {
      return nonDefaultable.currentMonthCompStream
    }

    private let weekdayDp: NNWeekdayDisplayModelDependency
    private let nonDefaultable: NNSelectableWeekdayNonDefaultableModelDependency

    internal init(_ dependency: NNSelectableWeekdayNonDefaultableModelDependency) {
      nonDefaultable = dependency
      weekdayDp = NNCalendar.WeekdayView.Model.DefaultDependency()
    }

    internal func weekdayDescription(_ weekday: Int) -> String {
      return weekdayDp.weekdayDescription(weekday)
    }
  }
}
