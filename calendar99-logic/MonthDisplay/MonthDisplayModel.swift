//
//  MonthDisplayModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency, so that the
/// model can expose the same properties.
public protocol NNMonthDisplayModelFunctionality: NNMonthControlModelDependency {

  /// Stream the initial components.
  var initialComponentStream: Single<NNCalendar.MonthComp> { get }
}

/// Dependency for month display model that contains components for which there
/// can be defaults. For e.g., we can default to the Sequential date calculator
/// for date range calculations.
public protocol NNMonthDisplayDefaultableModelDependency: NNDateCalculatorType {}

/// Dependency for month display model with non-defaultable components. These
/// must be provided by the injector.
public protocol NNMonthDisplayNonDefaultableModelDependency:
  NNMonthDisplayModelFunctionality {}

/// Dependency for month display model, comprising defaultable & non-defaultable
/// components.
public protocol NNMonthDisplayModelDependency:
  NNMonthDisplayDefaultableModelDependency,
  NNMonthDisplayNonDefaultableModelDependency {}

/// Factory for month display model dependency.
public protocol NNMonthDisplayModelDependencyFactory {

  /// Create a month display model dependency.
  ///
  /// - Returns: A MonthDisplayModelDependency instance.
  func monthDisplayModelDependency() -> NNMonthDisplayModelDependency
}

/// Model for month display view.
public protocol NNMonthDisplayModelType:
  NNMonthDisplayModelFunctionality,
  NNMonthControlModelType
{
  /// Calculate the Day range for a MonthComponent.
  ///
  /// - Parameters:
  ///   - comps: A MonthComponent instance.
  ///   - firstDayOfWeek: An Int value.
  ///   - rowCount: An Int value.
  ///   - columnCount: An Int value.
  /// - Returns: An Array of Day.
  func calculateDayRange(_ comps: NNCalendar.MonthComp,
                         _ firstDayOfWeek: Int,
                         _ rowCount: Int,
                         _ columnCount: Int) -> [NNCalendar.Day]
}

public extension NNCalendar.MonthDisplay {

  /// Month display model implementation.
  public final class Model {
    fileprivate let monthControlModel: NNMonthControlModelType
    fileprivate let dependency: NNMonthDisplayModelDependency

    required public init(_ monthControlModel: NNMonthControlModelType,
                         _ dependency: NNMonthDisplayModelDependency) {
      self.monthControlModel = monthControlModel
      self.dependency = dependency
    }

    convenience public init(_ dependency: NNMonthDisplayModelDependency) {
      let monthControlModel = NNCalendar.MonthControl.Model(dependency)
      self.init(monthControlModel, dependency)
    }

    convenience public init(_ dependency: NNMonthDisplayNonDefaultableModelDependency) {
      let defaultDP = DefaultDependency(dependency)
      self.init(defaultDP)
    }
  }
}

// MARK: - NNMonthControlModelType
extension NNCalendar.MonthDisplay.Model: NNMonthControlModelType {
  public func newComponents(_ prevComps: NNCalendar.MonthComp,
                            _ monthOffset: Int) -> NNCalendar.MonthComp? {
    return monthControlModel.newComponents(prevComps, monthOffset)
  }
}

// MARK: - NNMonthDisplayModelFunctionality
extension NNCalendar.MonthDisplay.Model: NNMonthDisplayModelFunctionality {
  public var initialComponentStream: Single<NNCalendar.MonthComp> {
    return dependency.initialComponentStream
  }

  public var currentComponentStream: Observable<NNCalendar.MonthComp> {
    return dependency.currentComponentStream
  }

  public var currentComponentReceiver: AnyObserver<NNCalendar.MonthComp> {
    return dependency.currentComponentReceiver
  }
}

// MARK: - NNMonthDisplayModelType
extension NNCalendar.MonthDisplay.Model: NNMonthDisplayModelType {
  public func calculateDayRange(_ comps: NNCalendar.MonthComp,
                                _ firstDayOfWeek: Int,
                                _ rowCount: Int,
                                _ columnCount: Int) -> [NNCalendar.Day] {
    let calendar = Calendar.current

    let dates = dependency.calculateRange(comps,
                                          firstDayOfWeek,
                                          rowCount,
                                          columnCount)

    return dates.map({
      let description = calendar.component(.day, from: $0).description

      return NNCalendar.Day(date: $0,
                            dateDescription: description,
                            isCurrentMonth: comps.contains($0))
    })
  }
}

// MARK: - Default dependency.
public extension NNCalendar.MonthDisplay.Model {

  /// Default dependency for month display model. This delegates non-defaultable
  /// components to a separate dependency.
  internal final class DefaultDependency: NNMonthDisplayModelDependency {
    public var initialComponentStream: Single<NNCalendar.MonthComp> {
      return nonDefaultable.initialComponentStream
    }

    private let nonDefaultable: NNMonthDisplayNonDefaultableModelDependency
    private let dateCalculator: NNDateCalculatorType

    public init(_ nonDefaultable: NNMonthDisplayNonDefaultableModelDependency) {
      self.nonDefaultable = nonDefaultable
      self.dateCalculator = NNCalendar.DateCalculator.Sequential()
    }

    /// We use a sequential date calculator here, since it seems to be the most
    /// common.
    public func calculateRange(_ comps: NNCalendar.MonthComp,
                               _ firstDayOfWeek: Int,
                               _ rowCount: Int,
                               _ columnCount: Int) -> [Date] {
      return dateCalculator.calculateRange(comps,
                                           firstDayOfWeek,
                                           rowCount,
                                           columnCount)
    }

    public var currentComponentStream: Observable<NNCalendar.MonthComp> {
      return nonDefaultable.currentComponentStream
    }

    public var currentComponentReceiver: AnyObserver<NNCalendar.MonthComp> {
      return nonDefaultable.currentComponentReceiver
    }
  }
}
