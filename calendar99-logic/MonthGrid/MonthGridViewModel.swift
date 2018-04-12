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
public protocol NNMonthGridViewModelFunctionality {

  /// Represents the number of columns. Should be 7 in most cases.
  var columnCount: Int { get }

  /// Represents the number of rows. Generally should be 6.
  var rowCount: Int { get }
}

/// Dependency for month-grid view model.
public protocol NNMonthGridViewModelDependency: NNMonthGridViewModelFunctionality {

  /// Get the first day of a week (e.g. Monday).
  var firstDayOfWeek: Int { get }
}

/// View model for month-grid based views.
public protocol NNMonthGridViewModelType:
  NNMonthGridFunctionality,
  NNMonthGridViewModelFunctionality
{
  /// Trigger grid item selection.
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

    public init(_ dependency: NNMonthGridViewModelDependency,
                _ model: NNMonthGridModelType) {
      self.dependency = dependency
      self.model = model
      gridSelectionSb = PublishSubject()
    }
  }
}

// MARK: - NNMonthGridViewModelFunctionality
extension NNCalendar.MonthGrid.ViewModel: NNMonthGridViewModelFunctionality {
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
