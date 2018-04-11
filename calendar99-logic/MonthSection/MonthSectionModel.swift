//
//  MonthSectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency, so that the
/// model expose the same properties.
public protocol NNMonthSectionModelFunctionality: NNMonthControlModelDependency {

  /// Stream the initial components.
  var initialComponentStream: Single<NNCalendar.MonthComp> { get }
}

/// Dependency for month section model, which contains components that can have
/// defaults.
public protocol NNMonthSectionDefaultableModelDependency: NNSingleDateCalculatorType {}

/// Dependency for month section model, which contains components that cannot
/// have defaults.
public protocol NNMonthSectionNonDefaultableModelDependency:
  NNMonthSectionModelFunctionality {}

/// Dependency for month section model.
public protocol NNMonthSectionModelDependency:
  NNMonthSectionDefaultableModelDependency,
  NNMonthSectionNonDefaultableModelDependency {}

/// Model for month section view.
public protocol NNMonthSectionModelType:
  NNMonthSectionModelFunctionality,
  NNMonthControlModelType
{
  /// Calculate the month component range, which is anchored by a specified
  /// month comp and goes as far back in the past/forward in the future as we
  /// want.
  ///
  /// - Parameters:
  ///   - currentComp: The current MonthComp.
  ///   - pastMonthCount: An Int value.
  ///   - futureMonthCount: An Int value.
  /// - Returns: An Array of MonthComp.
  func componentRange(_ currentComp: NNCalendar.MonthComp,
                      _ pastMonthCount: Int,
                      _ futureMonthCount: Int) -> [NNCalendar.MonthComp]

  /// Calculate the day for a month components and a first date offset.
  ///
  /// - Parameters:
  ///   - comps: A MonthComp instance.
  ///   - firstDayOfWeek: The first day in a week.
  ///   - firstDateOffset: Offset from the initial date in the grid.
  /// - Returns: A Day instance.
  func calculateDay(_ comps: NNCalendar.MonthComp,
                    _ firstDayOfWeek: Int,
                    _ firstDateOffset: Int) -> NNCalendar.Day?
}

public extension NNCalendar.MonthSection {

  /// Model implementation for month section view.
  public final class Model {

    /// Delegate display-related properties to this model.
    fileprivate let monthControlModel: NNMonthControlModelType
    fileprivate let dependency: NNMonthSectionModelDependency

    required public init(_ monthControlModel: NNMonthControlModelType,
                         _ dependency: NNMonthSectionModelDependency) {
      self.monthControlModel = monthControlModel
      self.dependency = dependency
    }

    convenience public init(_ dependency: NNMonthSectionModelDependency) {
      let monthControlModel = NNCalendar.MonthControl.Model(dependency)
      self.init(monthControlModel, dependency)
    }

    convenience public init(_ dependency: NNMonthSectionNonDefaultableModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }

    public func calculateDay(_ comps: NNCalendar.MonthComp,
                             _ firstDayOfWeek: Int,
                             _ firstDateOffset: Int) -> NNCalendar.Day? {
      return dependency.calculateDate(comps, firstDayOfWeek, firstDateOffset)
        .map({
          let description = Calendar.current.component(.day, from: $0).description

          return NNCalendar.Day(date: $0,
                                dateDescription: description,
                                isCurrentMonth: comps.contains($0))
        })
    }
  }
}

// MARK: - NNMonthSectionModelDependency
extension NNCalendar.MonthSection.Model: NNMonthSectionModelFunctionality {
  public var initialComponentStream: Single<NNCalendar.MonthComp> {
    return dependency.initialComponentStream
  }
}

// MARK: - NNMonthDisplayModelType
extension NNCalendar.MonthSection.Model: NNMonthControlModelType {
  public var currentComponentStream: Observable<NNCalendar.MonthComp> {
    return monthControlModel.currentComponentStream
  }

  public var currentComponentReceiver: AnyObserver<NNCalendar.MonthComp> {
    return monthControlModel.currentComponentReceiver
  }

  public func newComponents(_ prevComps: NNCalendar.MonthComp,
                            _ monthOffset: Int) -> NNCalendar.MonthComp? {
    return monthControlModel.newComponents(prevComps, monthOffset)
  }
}

// MARK: - NNMonthSectionModelType
extension NNCalendar.MonthSection.Model: NNMonthSectionModelType {
  public func componentRange(_ currentComp: NNCalendar.MonthComp,
                             _ pastMonthCount: Int,
                             _ futureMonthCount: Int) -> [NNCalendar.MonthComp] {
    let earliest = monthControlModel.newComponents(currentComp, -pastMonthCount)
    let totalMonths = pastMonthCount + 1 + futureMonthCount

    return (0..<totalMonths).flatMap({offset in
      earliest.flatMap({monthControlModel.newComponents($0, offset)})
    })
  }
}

extension NNCalendar.MonthSection.Model {

  /// Default dependency for month section model.
  internal final class DefaultDependency: NNMonthSectionModelDependency {
    public var initialComponentStream: Single<NNCalendar.MonthComp> {
      return nonDefaultable.initialComponentStream
    }

    public var currentComponentStream: Observable<NNCalendar.MonthComp> {
      return nonDefaultable.currentComponentStream
    }

    public var currentComponentReceiver: AnyObserver<NNCalendar.MonthComp> {
      return nonDefaultable.currentComponentReceiver
    }

    private let nonDefaultable: NNMonthSectionNonDefaultableModelDependency
    private let dateCalculator: NNSingleDateCalculatorType

    internal init(_ dependency: NNMonthSectionNonDefaultableModelDependency) {
      self.nonDefaultable = dependency
      dateCalculator = NNCalendar.DateCalculator.Sequential()
    }

    func calculateDate(_ comps: NNCalendar.MonthComp,
                       _ firstDayOfWeek: Int,
                       _ firstDateOffset: Int) -> Date? {
      return dateCalculator.calculateDate(comps, firstDayOfWeek, firstDateOffset)
    }
  }
}
