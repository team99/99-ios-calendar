//
//  DaySelectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Functionalities that can be exposed to the outside world.
public protocol NNDaySelectionModelFunctionality: NNDaySelectionFunctionality {

  /// Trigger date selections.
  var allDateSelectionReceiver: AnyObserver<Set<Date>> { get }

  /// Stream date selections.
  var allDateSelectionStream: Observable<Set<Date>> { get }
}

/// Dependency for day selection model.
public protocol NNDaySelectionModelDependency: NNDaySelectionModelFunctionality {}

/// Day selection model.
public protocol NNDaySelectionModelType: NNDaySelectionModelFunctionality {}

// MARK: - Model.
public extension NNCalendar.DaySelection {

  /// Model implementation for day selection views.
  public final class Model {
    fileprivate let dependency: NNDaySelectionModelDependency

    public init(_ dependency: NNDaySelectionModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - NNDaySelectionFunctionality
extension NNCalendar.DaySelection.Model: NNDaySelectionFunctionality {
  public func isDateSelected(_ date: Date) -> Bool {
    return dependency.isDateSelected(date)
  }
}

// MARK: - NNDaySelectionModelFunctionality
extension NNCalendar.DaySelection.Model: NNDaySelectionModelFunctionality {
  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return dependency.allDateSelectionReceiver
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return dependency.allDateSelectionStream
  }
}

// MARK: - NNDaySelectionModelType
extension NNCalendar.DaySelection.Model: NNDaySelectionModelType {}
