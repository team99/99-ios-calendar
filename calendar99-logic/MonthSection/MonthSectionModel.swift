//
//  MonthSectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared dependencies between the model and its dependency that can have
/// defaults.
public protocol NNMonthSectionDefaultModelFunction:
  NNMonthControlDefaultModelFunction,
  NNMultiMonthGridSelectionCalculator,
  NNSelectHighlightDefaultFunction,
  NNSingleDaySelectionDefaultModelDependency {}

/// Shared functionalities between the model and its dependency that cannot
/// have dependencies.
public protocol NNMonthSectionNoDefaultModelFunction:
  NNMonthControlNoDefaultModelFunction,
  NNSelectHighlightNoDefaultFunction,
  NNSingleDaySelectionNoDefaultModelDependency
{
  /// Get the number of past months to include in the month data stream.
  var pastMonthsFromCurrent: Int { get }

  /// Get the number of future months to include in the month data stream.
  var futureMonthsFromCurrent: Int { get }

  /// Stream the initial month.
  var initialMonthStream: Single<NNCalendar.Month> { get }
}

/// Dependency for month section model, which contains components that can have
/// defaults.
public protocol NNMonthSectionDefaultModelDependency:
  NNMonthSectionDefaultModelFunction,
  NNSingleDateCalculatorType {}

/// Dependency for month section model, which contains components that cannot
/// have defaults.
public protocol NNMonthSectionNoDefaultModelDependency:
  NNMonthControlModelDependency,
  NNMonthSectionNoDefaultModelFunction,
  NNSingleDaySelectionModelDependency {}

/// Dependency for month section model.
public protocol NNMonthSectionModelDependency:
  NNMonthSectionDefaultModelDependency,
  NNMonthSectionNoDefaultModelDependency,
  NNMonthGridModelDependency {}

/// Model for month section view.
public protocol NNMonthSectionModelType:
  NNMonthControlModelType,
  NNMonthGridModelType,
  NNMonthSectionDefaultModelFunction,
  NNMonthSectionNoDefaultModelFunction,
  NNSingleDaySelectionModelType
{
  /// Calculate the month range, which is anchored by a specified month and goes
  /// as far back in the past/forward in the future as we want.
  ///
  /// - Parameters:
  ///   - currentMonth: The current Month.
  ///   - pastMonths: An Int value.
  ///   - futureMonths: An Int value.
  /// - Returns: An Array of Month.
  func getAvailableMonths(_ currentMonth: NNCalendar.Month,
                          _ pastMonths: Int,
                          _ futureMonths: Int) -> [NNCalendar.Month]
  
  /// Calculate the day for a month and a first date offset (i.e. how distant
  /// the day is from the first date in the grid).
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - firstDateOffset: Offset from the initial date in the grid.
  /// - Returns: A Day instance.
  func calculateDayFromFirstDate(_ month: NNCalendar.Month,
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

// MARK: - NNGridDisplayDefaultFunction
extension NNCalendar.MonthSection.Model: NNGridDisplayDefaultFunction {
  public var columnCount: Int {
    return monthGridModel.columnCount
  }

  public var rowCount: Int {
    return monthGridModel.rowCount
  }
}

// MARK: - NNGridSelectionCalculatorType
extension NNCalendar.MonthSection.Model: NNMultiMonthGridSelectionCalculator {
  public func calculateGridSelection(_ monthComps: [NNCalendar.MonthComp],
                                     _ selection: Date)
    -> Set<NNCalendar.GridSelection>
  {
    return dependency.calculateGridSelection(monthComps, selection)
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension NNCalendar.MonthSection.Model: NNSingleDaySelectionNoDefaultFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionModel.isDateSelected(date)
  }
}

// MARK: - NNSelectHighlightNoDefaultFunction
extension NNCalendar.MonthSection.Model: NNSelectHighlightNoDefaultFunction {
  public func calculateHighlightPart(_ date: Date) -> NNCalendar.HighlightPart {
    return dependency.calculateHighlightPart(date)
  }
}

// MARK: - NNMonthSectionNoDefaultModelFunction
extension NNCalendar.MonthSection.Model: NNMonthSectionNoDefaultModelFunction {
  public var pastMonthsFromCurrent: Int {
    return dependency.pastMonthsFromCurrent
  }

  public var futureMonthsFromCurrent: Int {
    return dependency.futureMonthsFromCurrent
  }

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
  public func getAvailableMonths(_ currentComp: NNCalendar.Month,
                                 _ pastMonths: Int,
                                 _ futureMonths: Int) -> [NNCalendar.Month] {
    let earliest = currentComp.with(monthOffset: -pastMonths)
    let totalMonths = pastMonths + 1 + futureMonths

    return (0..<totalMonths).flatMap({offset in
      earliest.flatMap({$0.with(monthOffset: offset)})
    })
  }

  public func calculateDayFromFirstDate(_ month: NNCalendar.Month,
                                        _ firstDateOffset: Int)
    -> NNCalendar.Day?
  {
    return dependency.calculateDateWithOffset(month, firstDateOffset).map({
      let description = Calendar.current.component(.day, from: $0).description

      return NNCalendar.Day($0)
        .with(dateDescription: description)
        .with(currentMonth: month.contains($0))
    })
  }
}

extension NNCalendar.MonthSection.Model {

  /// Default dependency for month section model.
  internal final class DefaultDependency: NNMonthSectionModelDependency {
    internal var columnCount: Int { return monthGridDp.columnCount }
    internal var rowCount: Int { return monthGridDp.rowCount }

    internal var pastMonthsFromCurrent: Int {
      return noDefault.pastMonthsFromCurrent
    }

    internal var futureMonthsFromCurrent: Int {
      return noDefault.futureMonthsFromCurrent
    }

    internal var initialMonthStream: Single<NNCalendar.Month> {
      return noDefault.initialMonthStream
    }

    internal var currentMonthStream: Observable<NNCalendar.Month> {
      return noDefault.currentMonthStream
    }

    internal var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
      return noDefault.currentMonthReceiver
    }

    internal var allDateSelectionReceiver: AnyObserver<Set<Date>> {
      return noDefault.allDateSelectionReceiver
    }

    internal var allDateSelectionStream: Observable<Set<Date>> {
      return noDefault.allDateSelectionStream
    }

    private let noDefault: NNMonthSectionNoDefaultModelDependency
    private let monthGridDp: NNMonthGridModelDependency
    private let weekdayAwareDp: NNWeekdayAwareModelDependency
    private let dateCalc: NNCalendar.DateCalculator.Sequential

    internal init(_ dependency: NNMonthSectionNoDefaultModelDependency) {
      noDefault = dependency
      monthGridDp = NNCalendar.MonthGrid.Model.DefaultDependency()
      weekdayAwareDp = NNCalendar.WeekdayAware.Model.DefaultDependency()
      
      dateCalc = NNCalendar.DateCalculator.Sequential(
        monthGridDp.rowCount,
        monthGridDp.columnCount,
        weekdayAwareDp.firstWeekday)
    }

    internal func calculateDateWithOffset(_ month: NNCalendar.Month,
                                          _ firstDateOffset: Int) -> Date? {
      return dateCalc.calculateDateWithOffset(month, firstDateOffset)
    }

    internal func calculateGridSelection(_ monthComps: [NNCalendar.MonthComp],
                                         _ selection: Date)
      -> Set<NNCalendar.GridSelection>
    {
      return dateCalc.calculateGridSelection(monthComps, selection)
    }

    internal func isDateSelected(_ date: Date) -> Bool {
      return noDefault.isDateSelected(date)
    }

    internal func calculateHighlightPart(_ date: Date) -> NNCalendar.HighlightPart {
      return noDefault.calculateHighlightPart(date)
    }
  }
}
