//
//  SelectableWeekdayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency.
public protocol NNSelectableWeekdayModelFunction:
  NNWeekdayDisplayModelFunction,
  NNMonthAwareModelFunction,
  NNMultiDaySelectionModelFunction {}

/// Dependency for selectable weekday display whose components cannot have
/// defaults.
public protocol NNSelectableWeekdayNoDefaultModelDependency:
  NNMonthAwareModelDependency,
  NNMultiDaySelectionModelFunction {}

/// Dependency for selectable weekday display.
public protocol NNSelectableWeekdayModelDependency:
  NNSelectableWeekdayModelFunction,
  NNWeekdayDisplayModelDependency,
  NNSelectableWeekdayNoDefaultModelDependency {}

/// Model for selectable weekday display.
public protocol NNSelectableWeekdayModelType:
  NNSelectableWeekdayModelFunction,
  NNWeekdayDisplayModelType {}

// MARK: - Model.
public extension NNCalendar.SelectableWeekday {

  /// Model implementation.
  public final class Model {
    fileprivate let weekdayModel: NNWeekdayDisplayModelType
    fileprivate let dependency: NNSelectableWeekdayModelDependency

    required public init(_ weekdayModel: NNWeekdayDisplayModelType,
                         _ dependency: NNSelectableWeekdayModelDependency) {
      self.weekdayModel = weekdayModel
      self.dependency = dependency
    }

    convenience public init(_ dependency: NNSelectableWeekdayModelDependency) {
      let weekdayModel = NNCalendar.WeekdayDisplay.Model(dependency)
      self.init(weekdayModel, dependency)
    }

    convenience public init(_ dependency: NNSelectableWeekdayNoDefaultModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }
  }
}

// MARK: - NNMonthAwareModelFunction
extension NNCalendar.SelectableWeekday.Model: NNWeekdayDisplayModelFunction {
  public func weekdayDescription(_ weekday: Int) -> String {
    return weekdayModel.weekdayDescription(weekday)
  }
}

// MARK: - NNMonthAwareModelFunction
extension NNCalendar.SelectableWeekday.Model: NNMonthAwareModelFunction {
  public var currentMonthCompStream: Observable<NNCalendar.MonthComp> {
    return dependency.currentMonthCompStream
  }
}

// MARK: - NNMultiDaySelectionModelFunction
extension NNCalendar.SelectableWeekday.Model: NNMultiDaySelectionModelFunction {
  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return dependency.allDateSelectionReceiver
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return dependency.allDateSelectionStream
  }
}

// MARK: - NNSelectableWeekdayModelType
extension NNCalendar.SelectableWeekday.Model: NNSelectableWeekdayModelType {}

// MARK: - Default dependency.
public extension NNCalendar.SelectableWeekday.Model {
  internal final class DefaultDependency: NNSelectableWeekdayModelDependency {
    internal var currentMonthCompStream: Observable<NNCalendar.MonthComp> {
      return noDefault.currentMonthCompStream
    }

    internal var allDateSelectionReceiver: AnyObserver<Set<Date>> {
      return noDefault.allDateSelectionReceiver
    }

    internal var allDateSelectionStream: Observable<Set<Date>> {
      return noDefault.allDateSelectionStream
    }

    private let weekdayDp: NNWeekdayDisplayModelDependency
    private let noDefault: NNSelectableWeekdayNoDefaultModelDependency

    internal init(_ dependency: NNSelectableWeekdayNoDefaultModelDependency) {
      noDefault = dependency
      weekdayDp = NNCalendar.WeekdayDisplay.Model.DefaultDependency()
    }

    internal func weekdayDescription(_ weekday: Int) -> String {
      return weekdayDp.weekdayDescription(weekday)
    }
  }
}
