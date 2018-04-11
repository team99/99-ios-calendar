//
//  Model.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month header model.
public protocol NNMonthHeaderModelDependency:
  NNMonthHeaderFunctionality,
  NNMonthControlModelDependency
{
  /// Format month description.
  ///
  /// - Parameter components: A ControlComponents instance.
  /// - Returns: A String value.
  func formatMonthDescription(_ components: NNCalendar.MonthComponents) -> String
}

/// Factory for month header model dependency.
public protocol NNMonthHeaderDependencyFactory {

  /// Create a model dependency for month header view.
  ///
  /// - Returns: A Calendar99ModelDependency instance.
  func monthHeaderModelDependency() -> NNMonthHeaderModelDependency
}

/// Model for month header view.
public protocol NNMonthHeaderModelType:
  NNMonthHeaderModelDependency,
  NNMonthControlModelType {}

public extension NNCalendar.MonthHeader {

  /// Model implementation.
  public final class Model: NNMonthHeaderModelType {
    public var componentStream: Observable<NNCalendar.MonthComponents> {
      return monthControlModel.componentStream
    }

    public var initialComponentStream: Single<NNCalendar.MonthComponents> {
      return monthControlModel.initialComponentStream
    }

    public var componentReceiver: AnyObserver<NNCalendar.MonthComponents> {
      return monthControlModel.componentReceiver
    }

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

    public func newComponents(_ prevComponents: NNCalendar.MonthComponents,
                              _ monthOffset: Int) -> NNCalendar.MonthComponents? {
      return monthControlModel.newComponents(prevComponents, monthOffset)
    }

    public func formatMonthDescription(_ comps: NNCalendar.MonthComponents) -> String {
      return dependency.formatMonthDescription(comps)
    }
  }
}
