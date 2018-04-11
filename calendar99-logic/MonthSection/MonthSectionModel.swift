//
//  MonthSectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month section model, which contains components that can have
/// defaults.
public protocol NNMonthSectionDefaultableModelDependency:
  NNMonthDisplayDefaultableModelDependency {}

/// Dependency for month section model, which contains components that cannot
/// have defaults.
public protocol NNMonthSectionNonDefaultableModelDependency:
  NNMonthDisplayNonDefaultableModelDependency {}

/// Dependency for month section model. Since the month section view can be
/// considered a superset of the month view, many of the latter's functionalities
/// are repeated here.
public protocol NNMonthSectionModelDependency:
  NNMonthSectionDefaultableModelDependency,
  NNMonthSectionNonDefaultableModelDependency {}

/// Model for month section view.
public protocol NNMonthSectionModelType:
  NNMonthSectionModelDependency,
  NNMonthDisplayModelType
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
}

public extension NNCalendar.MonthSection {

  /// Model implementation for month section view.
  public final class Model {

    /// Delegate display-related properties to this model.
    fileprivate let monthDisplayModel: NNMonthDisplayModelType
    fileprivate let dependency: NNMonthSectionModelDependency

    required public init(_ monthDisplayModel: NNMonthDisplayModelType,
                         _ dependency: NNMonthSectionModelDependency) {
      self.monthDisplayModel = monthDisplayModel
      self.dependency = dependency
    }

    convenience public init(_ dependency: NNMonthSectionModelDependency) {
      let monthDisplayModel = NNCalendar.MonthDisplay.Model(dependency)
      self.init(monthDisplayModel, dependency)
    }

    convenience public init(_ dependency: NNMonthSectionNonDefaultableModelDependency) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp)
    }
  }
}

// MARK: - NNMonthSectionModelDependency
extension NNCalendar.MonthSection.Model: NNMonthSectionModelDependency {
  public var initialComponentStream: Single<NNCalendar.MonthComp> {
    return dependency.initialComponentStream
  }
}

// MARK: - NNMonthDisplayModelType
extension NNCalendar.MonthSection.Model: NNMonthDisplayModelType {
  public var currentComponentStream: Observable<NNCalendar.MonthComp> {
    return monthDisplayModel.currentComponentStream
  }

  public var currentComponentReceiver: AnyObserver<NNCalendar.MonthComp> {
    return monthDisplayModel.currentComponentReceiver
  }

  public func dateDescription(_ date: Date) -> String {
    return monthDisplayModel.dateDescription(date)
  }

  public func isInMonth(_ comps: NNCalendar.MonthComp, _ date: Date) -> Bool {
    return monthDisplayModel.isInMonth(comps, date)
  }

  public func calculateRange(_ comps: NNCalendar.MonthComp,
                             _ firstDayOfWeek: Int,
                             _ rowCount: Int,
                             _ columnCount: Int) -> [Date] {
    return monthDisplayModel.calculateRange(comps,
                                            firstDayOfWeek,
                                            rowCount,
                                            columnCount)
  }

  public func newComponents(_ prevComps: NNCalendar.MonthComp,
                            _ monthOffset: Int) -> NNCalendar.MonthComp? {
    return monthDisplayModel.newComponents(prevComps, monthOffset)
  }
}

// MARK: - NNMonthSectionModelType
extension NNCalendar.MonthSection.Model: NNMonthSectionModelType {
  public func componentRange(_ currentComp: NNCalendar.MonthComp,
                             _ pastMonthCount: Int,
                             _ futureMonthCount: Int) -> [NNCalendar.MonthComp] {
    let earliest = monthDisplayModel.newComponents(currentComp, pastMonthCount)
    let totalMonths = pastMonthCount + 1 + futureMonthCount

    return (0..<totalMonths).flatMap({offset in
      earliest.flatMap({monthDisplayModel.newComponents($0, offset)})
    })
  }
}

extension NNCalendar.MonthSection.Model {

  /// Default dependency for month section model.
  internal final class DefaultDependency: NNMonthSectionModelDependency {
    public var initialComponentStream: Single<NNCalendar.MonthComp> {
      return defaultable.initialComponentStream
    }

    public var currentComponentStream: Observable<NNCalendar.MonthComp> {
      return defaultable.currentComponentStream
    }

    public var currentComponentReceiver: AnyObserver<NNCalendar.MonthComp> {
      return defaultable.currentComponentReceiver
    }

    private let defaultable: NNMonthDisplayModelDependency

    internal init(_ dependency: NNMonthSectionNonDefaultableModelDependency) {
      defaultable = NNCalendar.MonthDisplay.Model.DefaultDependency(dependency)
    }

    func calculateRange(_ comps: NNCalendar.MonthComp,
                        _ firstDayOfWeek: Int,
                        _ rowCount: Int,
                        _ columnCount: Int) -> [Date] {
      return defaultable.calculateRange(comps,
                                        firstDayOfWeek,
                                        rowCount,
                                        columnCount)
    }
  }
}
