//
//  MonthSectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency, so that the
/// model can expose the same properties.
public protocol NNMonthSectionModelFunctionality {

  /// Stream the initial components.
  var initialMonthCompStream: Single<NNCalendar.MonthComp> { get }
}

/// Dependency for month section model, which contains components that can have
/// defaults.
public protocol NNMonthSectionDefaultableModelDependency:
  NNSingleDateCalculatorType,
  NNGridSelectionCalculatorType {}

/// Dependency for month section model, which contains components that cannot
/// have defaults.
public protocol NNMonthSectionNonDefaultableModelDependency:
  NNMonthSectionModelFunctionality,
  NNMonthControlModelDependency,
  NNMonthGridModelDependency,
  NNDaySelectionModelDependency {}

/// Dependency for month section model.
public protocol NNMonthSectionModelDependency:
  NNMonthSectionDefaultableModelDependency,
  NNMonthSectionNonDefaultableModelDependency {}

/// Model for month section view.
public protocol NNMonthSectionModelType:
  NNMonthSectionModelFunctionality,
  NNMonthControlModelType,
  NNMonthGridModelType,
  NNDaySelectionModelType,
  NNGridSelectionCalculatorType
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

  /// Calculate the day for a month components and a first date offset (i.e.
  /// how distant the day is from the first date in the grid).
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
    fileprivate let monthControlModel: NNMonthControlModelType
    fileprivate let monthGridModel: NNMonthGridModelType
    fileprivate let daySelectionModel: NNDaySelectionModelType
    fileprivate let dependency: NNMonthSectionModelDependency

    required public init(_ monthControlModel: NNMonthControlModelType,
                         _ monthGridModel: NNMonthGridModelType,
                         _ daySelectionModel: NNDaySelectionModelType,
                         _ dependency: NNMonthSectionModelDependency) {
      self.monthControlModel = monthControlModel
      self.monthGridModel = monthGridModel
      self.daySelectionModel = daySelectionModel
      self.dependency = dependency
    }

    convenience public init(_ dependency: NNMonthSectionModelDependency) {
      let monthControlModel = NNCalendar.MonthControl.Model(dependency)
      let monthGridModel = NNCalendar.MonthGrid.Model(dependency)
      let daySelectionModel = NNCalendar.DaySelection.Model(dependency)
      self.init(monthControlModel, monthGridModel, daySelectionModel, dependency)
    }

    convenience public init(_ dependency: NNMonthSectionNonDefaultableModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }
  }
}

// MARK: - NNGridSelectionCalculatorType
extension NNCalendar.MonthSection.Model: NNGridSelectionCalculatorType {
  public func calculateGridSelection(_ months: [NNCalendar.Month],
                                     _ firstDayOfWeek: Int,
                                     _ selection: Date)
    -> [NNCalendar.GridSelection]
  {
    return dependency.calculateGridSelection(months, firstDayOfWeek, selection)
  }
}

// MARK: - NNDaySelectionFunctionality
extension NNCalendar.MonthSection.Model: NNDaySelectionFunctionality {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionModel.isDateSelected(date)
  }
}

// MARK: - NNMonthSectionModelDependency
extension NNCalendar.MonthSection.Model: NNMonthSectionModelFunctionality {
  public var initialMonthCompStream: Single<NNCalendar.MonthComp> {
    return dependency.initialMonthCompStream
  }
}

// MARK: - NNMonthDisplayModelType
extension NNCalendar.MonthSection.Model: NNMonthControlModelType {
  public var currentMonthCompStream: Observable<NNCalendar.MonthComp> {
    return monthControlModel.currentMonthCompStream
  }

  public var currentMonthCompReceiver: AnyObserver<NNCalendar.MonthComp> {
    return monthControlModel.currentMonthCompReceiver
  }

  public func newComponents(_ prevComps: NNCalendar.MonthComp,
                            _ monthOffset: Int) -> NNCalendar.MonthComp? {
    return monthControlModel.newComponents(prevComps, monthOffset)
  }
}

// MARK: - NNDaySelectionModelType
extension NNCalendar.MonthSection.Model: NNDaySelectionModelType {
  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return daySelectionModel.allDateSelectionReceiver
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return daySelectionModel.allDateSelectionStream
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

  public func calculateDay(_ comps: NNCalendar.MonthComp,
                           _ firstDayOfWeek: Int,
                           _ firstDateOffset: Int) -> NNCalendar.Day? {
    return dependency.calculateDateWithOffset(comps, firstDayOfWeek, firstDateOffset).map({
      let description = Calendar.current.component(.day, from: $0).description

      return NNCalendar.Day(date: $0,
                            dateDescription: description,
                            isCurrentMonth: comps.contains($0),
                            isSelected: false)
    })
  }
}

extension NNCalendar.MonthSection.Model {

  /// Default dependency for month section model.
  internal final class DefaultDependency: NNMonthSectionModelDependency {
    public var initialMonthCompStream: Single<NNCalendar.MonthComp> {
      return nonDefaultable.initialMonthCompStream
    }

    public var currentMonthCompStream: Observable<NNCalendar.MonthComp> {
      return nonDefaultable.currentMonthCompStream
    }

    public var currentMonthCompReceiver: AnyObserver<NNCalendar.MonthComp> {
      return nonDefaultable.currentMonthCompReceiver
    }

    public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
      return nonDefaultable.allDateSelectionReceiver
    }

    public var allDateSelectionStream: Observable<Set<Date>> {
      return nonDefaultable.allDateSelectionStream
    }

    private let nonDefaultable: NNMonthSectionNonDefaultableModelDependency
    private let dateCalc: NNCalendar.DateCalculator.Sequential

    internal init(_ dependency: NNMonthSectionNonDefaultableModelDependency) {
      self.nonDefaultable = dependency
      dateCalc = NNCalendar.DateCalculator.Sequential()
    }

    internal func calculateDateWithOffset(_ comps: NNCalendar.MonthComp,
                                          _ firstDayOfWeek: Int,
                                          _ firstDateOffset: Int) -> Date? {
      return dateCalc.calculateDateWithOffset(comps, firstDayOfWeek, firstDateOffset)
    }

    internal func calculateGridSelection(_ months: [NNCalendar.Month],
                                         _ firstDayOfWeek: Int,
                                         _ selection: Date)
      -> [NNCalendar.GridSelection]
    {
      return dateCalc.calculateGridSelection(months, firstDayOfWeek, selection)
    }

    internal func isDateSelected(_ date: Date) -> Bool {
      return nonDefaultable.isDateSelected(date)
    }
  }
}
