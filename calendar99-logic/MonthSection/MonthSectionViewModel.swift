//
//  MonthSectionViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the view model and its dependency, so that
/// the former can expose the same properties.
public protocol NNMonthSectionViewModelFunctionality:
  NNMonthDisplayViewModelFunctionality {}

/// Dependency for month section view model with components that cannot have
/// defaults.
public protocol NNMonthSectionNonDefaultableViewModelDependency {

  /// Get the number of past months to include in the month data stream.
  var pastMonthCountFromCurrent: Int { get }

  /// Get the number of future months to include in the month data stream.
  var futureMonthCountFromCurrent: Int { get }
}

/// Dependency for month section view model.
public protocol NNMonthSectionViewModelDependency:
  NNMonthSectionNonDefaultableViewModelDependency,
  NNMonthDisplayViewModelDependency {}

/// View model for month section view.
public protocol NNMonthSectionViewModelType: NNMonthSectionViewModelFunctionality {

  /// Get the total month count.
  var totalMonthCount: Int { get }
  
  /// Stream months to display on the month section view.
  var monthStream: Observable<[NNCalendar.Month]> { get }

  /// Calculate the day for a month components and a first date offset.
  ///
  /// - Parameters:
  ///   - comps: A MonthComp instance.
  ///   - firstDateOffset: Offset from the initial date in the grid.
  /// - Returns: A Day instance.
  func calculateDay(_ comps: NNCalendar.MonthComp,
                    _ firstDateOffset: Int) -> NNCalendar.Day?
}

public extension NNCalendar.MonthSection {

  /// View model implementation for the month section view.
  public final class ViewModel {
    fileprivate let dependency: NNMonthSectionViewModelDependency
    fileprivate let model: NNMonthSectionModelType

    required public init(_ dependency: NNMonthSectionViewModelDependency,
                         _ model: NNMonthSectionModelType) {
      self.dependency = dependency
      self.model = model
    }

    convenience public init(
      _ dependency: NNMonthSectionNonDefaultableViewModelDependency,
      _ model: NNMonthSectionModelType)
    {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp, model)
    }
  }
}

// MARK: - NNMonthSectionViewModelFunctionality
extension NNCalendar.MonthSection.ViewModel: NNMonthSectionViewModelFunctionality {
  public var columnCount: Int {
    return dependency.columnCount
  }

  public var rowCount: Int {
    return dependency.rowCount
  }
}

// MARK: - NNMonthSectionViewModelType
extension NNCalendar.MonthSection.ViewModel: NNMonthSectionViewModelType {
  public var totalMonthCount: Int {
    return 1
      + dependency.pastMonthCountFromCurrent
      + dependency.futureMonthCountFromCurrent
  }

  public var monthStream: Observable<[NNCalendar.Month]> {
    let pCount = dependency.pastMonthCountFromCurrent
    let fCount = dependency.futureMonthCountFromCurrent
    let dayCount = dependency.rowCount * dependency.columnCount

    return model.initialComponentStream
      .map({[weak self] in self?.model.componentRange($0, pCount, fCount)})
      .filter({$0.isSome}).map({$0!})
      .map({$0.map({NNCalendar.Month($0, dayCount)})})
      .asObservable()
  }

  public func calculateDay(_ comps: NNCalendar.MonthComp,
                           _ firstDateOffset: Int) -> NNCalendar.Day? {
    return model.calculateDay(comps, dependency.firstDayOfWeek, firstDateOffset)
  }
}

// MARK: - Default dependency.
extension NNCalendar.MonthSection.ViewModel {

  /// Default dependency for month section view model. We reuse the default
  /// dependency for the month view because they have many similarities.
  internal final class DefaultDependency: NNMonthSectionViewModelDependency {
    public var pastMonthCountFromCurrent: Int {
      return nonDefaultable.pastMonthCountFromCurrent
    }

    public var futureMonthCountFromCurrent: Int {
      return nonDefaultable.futureMonthCountFromCurrent
    }

    public var firstDayOfWeek: Int {
      return defaultable.firstDayOfWeek
    }

    public var columnCount: Int {
      return defaultable.columnCount
    }

    public var rowCount: Int {
      return defaultable.rowCount
    }

    private let nonDefaultable: NNMonthSectionNonDefaultableViewModelDependency
    private let defaultable: NNMonthDisplayViewModelDependency

    internal init(_ dependency: NNMonthSectionNonDefaultableViewModelDependency) {
      self.nonDefaultable = dependency
      self.defaultable = NNCalendar.MonthDisplay.ViewModel.DefaultDependency()
    }
  }
}
