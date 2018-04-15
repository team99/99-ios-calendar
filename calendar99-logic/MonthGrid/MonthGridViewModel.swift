//
//  MonthGridViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities for the view model and its dependency for month-grid
/// views.
public protocol NNMonthGridViewModelFunction {

  /// Represents the number of columns. Should be 7 in most cases.
  var columnCount: Int { get }

  /// Represents the number of rows. Generally should be 6.
  var rowCount: Int { get }
}

/// Dependency for month-grid view model.
public protocol NNMonthGridViewModelDependency:
  NNMonthGridViewModelFunction,
  NNWeekdayAwareViewModelDependency {}

/// View model for month-grid based views.
public protocol NNMonthGridViewModelType: NNMonthGridViewModelFunction {

  /// Trigger grid item selection. Each grid selection corresponds to an Index
  /// Path in the current month grid.
  var gridSelectionReceiver: AnyObserver<NNCalendar.GridSelection> { get }

  /// Stream grid selections.
  var gridSelectionStream: Observable<NNCalendar.GridSelection> { get }
}

// MARK: - Month grid view model.
public extension NNCalendar.MonthGrid {

  /// View model implementation for month grid view.
  public final class ViewModel {
    fileprivate let dependency: NNMonthGridViewModelDependency
    fileprivate let model: NNMonthGridModelType
    fileprivate let gridSelectionSb: PublishSubject<NNCalendar.GridSelection>

    required public init(_ dependency: NNMonthGridViewModelDependency,
                         _ model: NNMonthGridModelType) {
      self.dependency = dependency
      self.model = model
      gridSelectionSb = PublishSubject()
    }

    convenience public init(_ model: NNMonthGridModelType) {
      let defaultDp = DefaultDependency()
      self.init(defaultDp, model)
    }
  }
}

// MARK: - NNMonthGridViewModelFunction
extension NNCalendar.MonthGrid.ViewModel: NNMonthGridViewModelFunction {
  public var columnCount: Int {
    return dependency.columnCount
  }

  public var rowCount: Int {
    return dependency.rowCount
  }
}

// MARK: - NNMonthGridViewModelType
extension NNCalendar.MonthGrid.ViewModel: NNMonthGridViewModelType {
  public var gridSelectionStream: Observable<NNCalendar.GridSelection> {
    return gridSelectionSb.asObservable()
  }

  public var gridSelectionReceiver: AnyObserver<NNCalendar.GridSelection> {
    return gridSelectionSb.asObserver()
  }
}

// MARK: - Default dependency.
public extension NNCalendar.MonthGrid.ViewModel {
  internal final class DefaultDependency: NNMonthGridViewModelDependency {

    /// Corresponds to 7 days in a week.
    internal var columnCount: Int {
      return 7
    }

    /// Seems like most calendar apps have 6 rows, so in total 42 date cells.
    internal var rowCount: Int {
      return 6
    }

    /// Corresponds to a Sunday.
    internal var firstWeekday: Int {
      return weekdayAwareDp.firstWeekday
    }

    private let weekdayAwareDp: NNWeekdayAwareViewModelDependency

    internal init() {
      weekdayAwareDp = NNCalendar.WeekdayAware.ViewModel.DefaultDependency()
    }
  }
}
