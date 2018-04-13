//
//  SingleDaySelectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Functionalities that can be exposed to the outside world.
public protocol NNSingleDaySelectionModelFunction:
  NNSingleDaySelectionFunction,
  NNMultiDaySelectionModelFunction {}

/// Dependency for day selection model.
public protocol NNSingleDaySelectionModelDependency:
  NNSingleDaySelectionModelFunction {}

/// Day selection model.
public protocol NNSingleDaySelectionModelType:
  NNSingleDaySelectionModelFunction {}

// MARK: - Model.
public extension NNCalendar.DaySelection {

  /// Model implementation for day selection views.
  public final class Model {
    fileprivate let dependency: NNSingleDaySelectionModelDependency

    public init(_ dependency: NNSingleDaySelectionModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - NNDaySelectionFunction
extension NNCalendar.DaySelection.Model: NNSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return dependency.isDateSelected(date)
  }
}

// MARK: - NNDaySelectionModelFunction
extension NNCalendar.DaySelection.Model: NNSingleDaySelectionModelFunction {
  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return dependency.allDateSelectionReceiver
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return dependency.allDateSelectionStream
  }
}

// MARK: - NNDaySelectionModelType
extension NNCalendar.DaySelection.Model: NNSingleDaySelectionModelType {}
