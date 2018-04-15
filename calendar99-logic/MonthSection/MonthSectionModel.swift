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
public protocol NNMonthSectionModelFunction {

  /// Stream the initial month.
  var initialMonthStream: Single<NNCalendar.Month> { get }
}

/// Dependency for month section model, which contains components that can have
/// defaults.
public protocol NNMonthSectioDefaultModelDependency:
  NNSingleDateCalculatorType,
  NNMultiMonthGridSelectionCalculator {}

/// Dependency for month section model, which contains components that cannot
/// have defaults.
public protocol NNMonthSectionNoDefaultModelDependency:
  NNMonthSectionModelFunction,
  NNMonthControlModelDependency,
  NNMonthGridModelDependency,
  NNSingleDaySelectionModelDependency {}

/// Dependency for month section model.
public protocol NNMonthSectionModelDependency:
  NNMonthSectioDefaultModelDependency,
  NNMonthSectionNoDefaultModelDependency {}

/// Model for month section view.
public protocol NNMonthSectionModelType:
  NNMonthSectionModelFunction,
  NNMonthControlModelType,
  NNMonthGridModelType,
  NNSingleDaySelectionModelType,
  NNMultiMonthGridSelectionCalculator
{
  /// Calculate the month range, which is anchored by a specified month and goes
  /// as far back in the past/forward in the future as we want.
  ///
  /// - Parameters:
  ///   - currentMonth: The current Month.
  ///   - pastMonthCount: An Int value.
  ///   - futureMonthCount: An Int value.
  /// - Returns: An Array of Month.
  func componentRange(_ currentMonth: NNCalendar.Month,
                      _ pastMonthCount: Int,
                      _ futureMonthCount: Int) -> [NNCalendar.Month]

  /// Calculate the day for a month and a first date offset (i.e. how distant
  /// the day is from the first date in the grid).
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - firstWeekday: The first day in a week.
  ///   - firstDateOffset: Offset from the initial date in the grid.
  /// - Returns: A Day instance.
  func calculateDayFromFirstDate(_ month: NNCalendar.Month,
                                 _ firstWeekday: Int,
                                 _ firstDateOffset: Int) -> NNCalendar.Day?
}

public extension NNCalendar.MonthSection {

  /// Model implementation for month section view.
  public final class Model {
    fileprivate let monthControlModel: NNMonthControlModelType
    fileprivate let monthGridModel: NNMonthGridModelType
    fileprivate let daySelectionModel: NNSingleDaySelectionModelType
    fileprivate let dependency: NNMonthSectionModelDependency

    required public init(_ monthControlModel: NNMonthControlModelType,
                         _ monthGridModel: NNMonthGridModelType,
                         _ daySelectionModel: NNSingleDaySelectionModelType,
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

    convenience public init(_ dependency: NNMonthSectionNoDefaultModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }
  }
}

// MARK: - NNGridSelectionCalculatorType
extension NNCalendar.MonthSection.Model: NNMultiMonthGridSelectionCalculator {
  public func calculateGridSelection(_ monthComps: [NNCalendar.MonthComp],
                                     _ firstWeekday: Int,
                                     _ selection: Date)
    -> Set<NNCalendar.GridSelection>
  {
    return dependency.calculateGridSelection(monthComps, firstWeekday, selection)
  }
}

// MARK: - NNDaySelectionFunction
extension NNCalendar.MonthSection.Model: NNSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionModel.isDateSelected(date)
  }
}

// MARK: - NNMonthSectionModelDependency
extension NNCalendar.MonthSection.Model: NNMonthSectionModelFunction {
  public var initialMonthStream: Single<NNCalendar.Month> {
    return dependency.initialMonthStream
  }
}

// MARK: - NNMonthDisplayModelType
extension NNCalendar.MonthSection.Model: NNMonthControlModelType {
  public var currentMonthStream: Observable<NNCalendar.Month> {
    return monthControlModel.currentMonthStream
  }

  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return monthControlModel.currentMonthReceiver
  }
}

// MARK: - NNDaySelectionModelType
extension NNCalendar.MonthSection.Model: NNSingleDaySelectionModelType {
  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return daySelectionModel.allDateSelectionReceiver
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return daySelectionModel.allDateSelectionStream
  }
}

// MARK: - NNMonthSectionModelType
extension NNCalendar.MonthSection.Model: NNMonthSectionModelType {
  public func componentRange(_ currentComp: NNCalendar.Month,
                             _ pastMonthCount: Int,
                             _ futureMonthCount: Int) -> [NNCalendar.Month] {
    let earliest = currentComp.with(monthOffset: -pastMonthCount)
    let totalMonths = pastMonthCount + 1 + futureMonthCount

    return (0..<totalMonths).flatMap({offset in
      earliest.flatMap({$0.with(monthOffset: offset)})
    })
  }

  public func calculateDayFromFirstDate(_ month: NNCalendar.Month,
                                        _ firstWeekday: Int,
                                        _ firstDateOffset: Int) -> NNCalendar.Day? {
    return dependency.calculateDateWithOffset(month, firstWeekday, firstDateOffset).map({
      let description = Calendar.current.component(.day, from: $0).description

      return NNCalendar.Day(date: $0,
                            dateDescription: description,
                            isCurrentMonth: month.contains($0),
                            isSelected: false)
    })
  }
}

extension NNCalendar.MonthSection.Model {

  /// Default dependency for month section model.
  internal final class DefaultDependency: NNMonthSectionModelDependency {
    public var initialMonthStream: Single<NNCalendar.Month> {
      return noDefault.initialMonthStream
    }

    public var currentMonthStream: Observable<NNCalendar.Month> {
      return noDefault.currentMonthStream
    }

    public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
      return noDefault.currentMonthReceiver
    }

    public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
      return noDefault.allDateSelectionReceiver
    }

    public var allDateSelectionStream: Observable<Set<Date>> {
      return noDefault.allDateSelectionStream
    }

    private let noDefault: NNMonthSectionNoDefaultModelDependency
    private let dateCalc: NNCalendar.DateCalculator.Sequential

    internal init(_ dependency: NNMonthSectionNoDefaultModelDependency) {
      self.noDefault = dependency
      dateCalc = NNCalendar.DateCalculator.Sequential()
    }

    internal func calculateDateWithOffset(_ month: NNCalendar.Month,
                                          _ firstWeekday: Int,
                                          _ firstDateOffset: Int) -> Date? {
      return dateCalc.calculateDateWithOffset(month, firstWeekday, firstDateOffset)
    }

    internal func calculateGridSelection(_ monthComps: [NNCalendar.MonthComp],
                                         _ firstWeekday: Int,
                                         _ selection: Date)
      -> Set<NNCalendar.GridSelection>
    {
      return dateCalc.calculateGridSelection(monthComps, firstWeekday, selection)
    }

    internal func isDateSelected(_ date: Date) -> Bool {
      return noDefault.isDateSelected(date)
    }
  }
}
