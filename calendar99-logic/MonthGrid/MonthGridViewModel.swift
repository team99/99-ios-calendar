//
//  MonthGridViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for month-grid based views.
public protocol NNMonthGridViewModelType:
  NNGridDisplayDefaultFunction,
  NNGridDisplayNoDefaultFunction
{
  /// Trigger grid item selection. Each grid selection corresponds to an Index
  /// Path in the current month grid.
  var gridSelectionReceiver: AnyObserver<NNCalendar.GridPosition> { get }

  /// Stream grid selections.
  var gridSelectionStream: Observable<NNCalendar.GridPosition> { get }
}

// MARK: - ViewModel.
public extension NNCalendar.MonthGrid {

  /// View model implementation for month grid view.
  public final class ViewModel {
    fileprivate let model: NNMonthGridModelType
    fileprivate let gridSelectionSb: PublishSubject<NNCalendar.GridPosition>

    required public init(_ model: NNMonthGridModelType) {
      self.model = model
      gridSelectionSb = PublishSubject()
    }
  }
}

// MARK: - NNGridDisplayDefaultFunction
extension NNCalendar.MonthGrid.ViewModel: NNGridDisplayDefaultFunction {
  public var columnCount: Int {
    return model.columnCount
  }

  public var rowCount: Int {
    return model.rowCount
  }
}

// MARK: - NNMonthGridViewModelType
extension NNCalendar.MonthGrid.ViewModel: NNMonthGridViewModelType {
  public var gridSelectionStream: Observable<NNCalendar.GridPosition> {
    return gridSelectionSb.asObservable()
  }

  public var gridSelectionReceiver: AnyObserver<NNCalendar.GridPosition> {
    return gridSelectionSb.asObserver()
  }
}
