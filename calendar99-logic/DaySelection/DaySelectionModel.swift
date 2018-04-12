//
//  DaySelectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency so that the
/// model exposes the same properties.
public protocol NNDaySelectionModelFunctionality: NNDaySelectionFunctionality {

  /// Trigger date selections.
  var dateSelectionReceiver: AnyObserver<Set<Date>> { get }

  /// Stream date selections.
  var dateSelectionStream: Observable<Set<Date>> { get }
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

// MARK: - NNDaySelectionModelFunctionality
extension NNCalendar.DaySelection.Model: NNDaySelectionModelFunctionality {
  public var dateSelectionReceiver: AnyObserver<Set<Date>> {
    return dependency.dateSelectionReceiver
  }

  public var dateSelectionStream: Observable<Set<Date>> {
    return dependency.dateSelectionStream
  }
}

// MARK: - NNDaySelectionModelType
extension NNCalendar.DaySelection.Model: NNDaySelectionModelType {}
