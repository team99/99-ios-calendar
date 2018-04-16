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
public protocol NNMonthGridViewModelFunction: NNGridDisplayViewModelFunction {}

/// Dependency for month-grid view model.
public protocol NNMonthGridViewModelDependency:
  NNMonthGridViewModelFunction,
  NNMGridDisplayViewModelDependency,
  NNWeekdayAwareViewModelDependency {}

/// View model for month-grid based views.
public protocol NNMonthGridViewModelType:
  NNMonthGridViewModelFunction,
  NNGridDisplayViewModelType
{
  /// Trigger grid item selection. Each grid selection corresponds to an Index
  /// Path in the current month grid.
  var gridSelectionReceiver: AnyObserver<NNCalendar.GridSelection> { get }

  /// Stream grid selections.
  var gridSelectionStream: Observable<NNCalendar.GridSelection> { get }
}

// MARK: - ViewModel.
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
    internal var columnCount: Int {
      return gridDisplayDp.columnCount
    }

    internal var rowCount: Int {
      return gridDisplayDp.rowCount
    }

    internal var firstWeekday: Int {
      return weekdayAwareDp.firstWeekday
    }

    private let gridDisplayDp: NNMGridDisplayViewModelDependency
    private let weekdayAwareDp: NNWeekdayAwareViewModelDependency

    internal init() {
      gridDisplayDp = NNCalendar.GridDisplay.ViewModel.DefaultDependency()
      weekdayAwareDp = NNCalendar.WeekdayAware.ViewModel.DefaultDependency()
    }
  }
}
