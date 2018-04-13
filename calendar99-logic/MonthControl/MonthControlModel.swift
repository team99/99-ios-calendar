//
//  MonthControlModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month control model.
public protocol NNMonthControlModelDependency {

  /// Stream the current selected components.
  var currentMonthCompStream: Observable<NNCalendar.MonthComp> { get }

  /// Receive the current components.
  var currentMonthCompReceiver: AnyObserver<NNCalendar.MonthComp> { get }
}

/// Model for month header view.
public protocol NNMonthControlModelType: NNMonthControlModelDependency {}

internal extension NNCalendar.MonthControl {

  /// Model implementation.
  internal final class Model {
    fileprivate let dependency: NNMonthControlModelDependency

    public init(_ dependency: NNMonthControlModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - NNMonthControlModelDependency
extension NNCalendar.MonthControl.Model: NNMonthControlModelDependency {
  public var currentMonthCompStream: Observable<NNCalendar.MonthComp> {
    return dependency.currentMonthCompStream
  }

  public var currentMonthCompReceiver: AnyObserver<NNCalendar.MonthComp> {
    return dependency.currentMonthCompReceiver
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendar.MonthControl.Model: NNMonthControlModelType {}
