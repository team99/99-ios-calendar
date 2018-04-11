//
//  Model.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month header model.
public protocol NNMonthHeaderModelDependency: NNMonthControlModelDependency {
  
  /// Format month description.
  ///
  /// - Parameter components: A ControlComponents instance.
  /// - Returns: A String value.
  func formatMonthDescription(_ comps: NNCalendar.MonthComp) -> String
}

/// Model for month header view.
public protocol NNMonthHeaderModelType:
  NNMonthHeaderModelDependency,
  NNMonthControlModelType {}

public extension NNCalendar.MonthHeader {

  /// Model implementation.
  public final class Model {
    /// Delegate month-related calculations to this model.
    fileprivate let monthControlModel: NNMonthControlModelType
    fileprivate let dependency: NNMonthHeaderModelDependency

    required public init(_ monthControlModel: NNMonthControlModelType,
                         _ dependency: NNMonthHeaderModelDependency) {
      self.dependency = dependency
      self.monthControlModel = monthControlModel
    }

    convenience public init(_ dependency: NNMonthHeaderModelDependency) {
      let monthControlModel = NNCalendar.MonthControl.Model(dependency)
      self.init(monthControlModel, dependency)
    }
  }
}

// MARK: - NNMonthHeaderModelDependency
extension NNCalendar.MonthHeader.Model: NNMonthHeaderModelDependency {
  public func formatMonthDescription(_ comps: NNCalendar.MonthComp) -> String {
    return dependency.formatMonthDescription(comps)
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendar.MonthHeader.Model: NNMonthControlModelType {
  public var currentComponentStream: Observable<NNCalendar.MonthComp> {
    return monthControlModel.currentComponentStream
  }

  public var currentComponentReceiver: AnyObserver<NNCalendar.MonthComp> {
    return monthControlModel.currentComponentReceiver
  }

  public func newComponents(_ prevComponents: NNCalendar.MonthComp,
                            _ monthOffset: Int) -> NNCalendar.MonthComp? {
    return monthControlModel.newComponents(prevComponents, monthOffset)
  }
}

// MARK: - NNMonthHeaderModelType
extension NNCalendar.MonthHeader.Model: NNMonthHeaderModelType {}
