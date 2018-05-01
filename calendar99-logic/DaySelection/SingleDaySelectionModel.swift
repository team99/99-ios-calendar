//
//  SingleDaySelectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared functionalities between the model and its dependency.
public protocol NNSingleDaySelectionModelFunction:
  NNMultiDaySelectionFunction,
  NNSingleDaySelectionFunction {}

/// Dependency for single day selection model.
public protocol NNSingleDaySelectionModelDependency:
  NNSingleDaySelectionModelFunction,
  NNWeekdayAwareModelDependency {}

/// Day selection model.
public protocol NNSingleDaySelectionModelType:
  NNSingleDaySelectionModelFunction,
  NNWeekdayAwareModelType {}

// MARK: - Model.
public extension NNCalendarLogic.DaySelect {

  /// Model implementation for day selection views.
  public final class Model {
    fileprivate let dependency: NNSingleDaySelectionModelDependency

    required public init(_ dependency: NNSingleDaySelectionModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - NNMultiDaySelectionFunction
extension NNCalendarLogic.DaySelect.Model: NNMultiDaySelectionFunction {
  public var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    return dependency.allSelectionReceiver
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
    return dependency.allSelectionStream
  }
}

// MARK: - NNSingleDaySelectionFunction
extension NNCalendarLogic.DaySelect.Model: NNSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return dependency.isDateSelected(date)
  }
}

// MARK: - NNSingleDaySelectionModelType
extension NNCalendarLogic.DaySelect.Model: NNSingleDaySelectionModelType {}

// MARK: - NNWeekdayAwareModelFunction
extension NNCalendarLogic.DaySelect.Model: NNWeekdayAwareModelFunction {
  public var firstWeekday: Int {
    return dependency.firstWeekday
  }
}
